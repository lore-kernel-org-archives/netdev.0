From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [GIT] Networking
Date: Thu, 03 May 2012 14:36:57 +0530
Message-ID: <4FA24AB1.9010108@linux.vnet.ibm.com>
References: <20120503.025951.1393913795357644010.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bpoirier@suse.de, jeffrey.t.kirsher@intel.com,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Linux PM mailing list <linux-pm@vger.kernel.org>,
	stephen.s.ko@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120503.025951.1393913795357644010.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/03/2012 12:29 PM, David Miller wrote:

> 
> It's the usual jumble of small fixes, mostly in drivers, but a few in
> core infrastructure parts and TCP.
> 
> 1) Transfer padding was wrong for full-speed USB in ASIX driver,
>    fix from Ingo van Lil.
> 
> 2) Propagate the negative packet offset fix into the PowerPC BPF JIT.
>    From Jan Seiffert.
> 
> 3) dl2k driver's private ioctls were letting unprivileged tasks make
>    MII writes and other ugly bits like that.  Fix from Jeff Mahoney.
> 
> 4) Fix TX VLAN and RX packet drops in ucc_geth, from Joakim Tjernlund.
> 
> 5) OOPS and network namespace fixes in IPVS from Hans Schillstrom and
>    Julian Anastasov.
> 
> 6) Fix races and sleeping in locked context bugs in drop_monitor, from
>    Neil Horman.
> 
> 7) Fix link status indication in smsc95xx driver, from Paolo Pisati.
> 
> 8) Fix bridge netfilter OOPS, from Peter Huang.
> 
> 9) L2TP sendmsg can return on error conditions with the socket lock
>    held, oops.  Fix from Sasha Levin.
> 
> 10) udp_diag should return meaningful values for socket memory usage,
>     from Shan Wei.
> 
> 11) Eric Dumazet is so awesome he gets his own section:
> 
> 	Socket memory cgroup code (I never should have applied those
> 	patches, grumble...) made erroneous changes to
> 	sk_sockets_allocated_read_positive().  It was changed to
> 	use percpu_counter_sum_positive (which requires BH disabling)
> 	instead of percpu_counter_read_positive (which does not).
> 	Revert back to avoid crashes and lockdep warnings.
> 
> 	Adjust the default tcp_adv_win_scale and tcp_rmem[2] values
> 	to fix throughput regressions.  This is necessary as a result
> 	of our more precise skb->truesize tracking.
> 
> 	Fix SKB leak in netem packet scheduler.
> 
> 12) New device IDs for various bluetooth devices, from Manoj Iyer,
>     AceLan Kao, and Steven Harms.
> 
> 13) Fix command completion race in ipw2200, from Stanislav Yakovlev.
> 
> 14) Fix rtlwifi oops on unload, from Larry Finger.
> 
> 15) Fix hard_mtu when adjusting hard_header_len in smsc95xx driver. From
>     Stephane Fillod.
> 
> 16) ehea driver registers it's IRQ before all the necessary state is
>     setup, resulting in crashes.  Fix from Thadeu Lima de Souza
>     Cascardo.
> 
> 17) Fix PHY connection failures in davinci_emac driver, from Anatolij
>     Gustschin.
> 
> 18) Missing break; in switch statement in bluetooth's
>     hci_cmd_complete_evt().  Fix from Szymon Janc.
> 
> 19) Fix queue programming in iwlwifi, from Johannes Berg.
> 
> 20) Interrupt throttling defaults not being actually programmed
>     into the hardware, fix from Jeff Kirsher and Ying Cai.
> 
> 21) TLAN driver SKB encoding in descriptor busted on 64-bit, fix
>     from Benjamin Poirier.
> 
> 22) Fix blind status block RX producer pointer deref in TG3 driver,
>     from Matt Carlson.
> 
> 23) Promisc and multicast are busted on ehea, fixes from Thadeu Lima
>     de Souza Cascardo.
> 
> 24) Fix crashes in 6lowpan, from Alexander Smirnov.
> 
> 25) tcp_complete_cwr() needs to be careful to not rewind the CWND to
>     ssthresh if ssthresh has the "infinite" value.  Fix from Yuchung
>     Cheng.
> 
> Please pull, thanks a lot.
> 
> The following changes since commit 4d634ca35a8b38530b134ae92bc9e3cc9c23c030:
> 
>   Merge branch 'rc-fixes' of git://git.kernel.org/pub/scm/linux/kernel/git/mmarek/kbuild (2012-04-23 19:45:19 -0700)
> 
> are available in the git repository at:
> 
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master
> 
> for you to fetch changes up to 5a8887d39e1ba5ee2d4ccb94b14d6f2dce5ddfca:
> 
>   sungem: Fix WakeOnLan (2012-05-03 01:42:55 -0400)
> 
> ----------------------------------------------------------------
> AceLan Kao (2):
>       Bluetooth: Add support for Atheros [13d3:3362]
>       Bluetooth: Add support for AR3012 [0cf3:e004]
> 
> Alexander Duyck (1):
>       ixgbe: Fix a memory leak in IEEE DCB
> 
> Anatolij Gustschin (1):
>       net/davinci_emac: fix failing PHY connect attempts
> 
> Benjamin Poirier (1):
>       tlan: add cast needed for proper 64 bit operation
> 


Oh, looks like even this pull request missed the igb fix from Benjamin.
https://lkml.org/lkml/2012/4/5/197

I don't mean to rush things, but my only concern here is to ensure that
this patch doesn't get lost, because the fix is important, is stable
material (I see warnings/stacktraces during suspend/resume in stable
kernels very frequently and this patch fixes it) and a similar fix for
ixgbe (patch 2/2 in that patchset, https://lkml.org/lkml/2012/4/5/198)
went upstream in a previous -rc (commit 34948a947d), while this one got
left out...

In case the above mentioned patch is already in the pipeline, sorry for
the noise..

Regards,

Srivatsa S. Bhat
IBM Linux Technology Center
