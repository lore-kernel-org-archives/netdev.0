From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: 2.6.23-rc4-mm1: e1000e napi lockup
Date: Fri, 07 Sep 2007 16:40:14 -0700
Message-ID: <46E1E15E.7080406@intel.com>
References: <46E0FB82.2040000@gmail.com>
	<20070907.010338.41638771.davem@davemloft.net>
	<46E17B41.4060200@intel.com> <46E1DF6E.6050801@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org, David Miller <davem@davemloft.net>,
	jirislaby@gmail.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <46E1DF6E.6050801@garzik.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Kok, Auke wrote:
>> David Miller wrote:
>>> From: Jiri Slaby <jirislaby@gmail.com>
>>> Date: Fri, 07 Sep 2007 09:19:30 +0200
>>>
>>>> I found a regression in 2.6.23-rc4-mm1 (since -rc3-mm1) in e1000e 
>>>> driver.
>>>> napi_disable(&adapter->napi) in e1000_probe freezes the kernel on boot.
>>> Yes, the semantics changed slightly in the net-2.6.24 tree the
>>> other week and someone needs to fix it up.
>>>
>>> The netif_napi_add() implicitly does a napi_disable() call.  Device
>>> open must explicitly napi_enable() and device close must explicitly
>>> napi_disable(), and if done elsewhere these calls must be strictly
>>> balanced.
>> I'll fix it... it's my patch that adds the new napi code to it and I 
>> need to get it ready for the merge window anyway.
> 
> well....  since its close to the merge window opening, we could see what 
> happens if DaveM pulls branch 'upstream' of 
> git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git
> 
> That should make this class of pre-merge-window annoyance go away.

If I do that now I get a big merge conflict:

$ git-pull . net-2.6.24
  100% (22583/22583) done
Removed Documentation/networking/NAPI_HOWTO.txt
Auto-merged drivers/net/8139cp.c
Auto-merged drivers/net/8139too.c
CONFLICT (content): Merge conflict in drivers/net/8139too.c
Auto-merged drivers/net/Kconfig
Auto-merged drivers/net/Makefile
Auto-merged drivers/net/cxgb3/cxgb3_main.c
Auto-merged drivers/net/cxgb3/sge.c
Auto-merged drivers/net/fs_enet/fs_enet-main.c
Auto-merged drivers/net/gianfar.h
Auto-merged drivers/net/ibmveth.c
CONFLICT (content): Merge conflict in drivers/net/ibmveth.c
Auto-merged drivers/net/ibmveth.h
Auto-merged drivers/net/myri10ge/myri10ge.c
Auto-merged drivers/net/netxen/netxen_nic_main.c
Auto-merged drivers/net/pasemi_mac.c
CONFLICT (content): Merge conflict in drivers/net/pasemi_mac.c
Auto-merged drivers/net/pasemi_mac.h
Auto-merged drivers/net/pcnet32.c
Auto-merged drivers/net/ps3_gelic_net.c
Auto-merged drivers/net/qla3xxx.c
Auto-merged drivers/net/s2io.c
CONFLICT (content): Merge conflict in drivers/net/s2io.c
Auto-merged drivers/net/s2io.h
Auto-merged drivers/net/sb1250-mac.c
Auto-merged drivers/net/sky2.c
Auto-merged drivers/net/sky2.h
Auto-merged drivers/net/tsi108_eth.c
Auto-merged drivers/net/wireless/rtl8187_dev.c
Auto-merged drivers/net/xen-netfront.c
Removed include/net/tcp_ecn.h
Automatic merge failed; fix conflicts and then commit the result.


for e1000e the fixup is just a 1-line change from the previous -mm napi fixup 
patch, so I don't really care (it's peanuts), but people might want to start 
looking into the above conflicts ;)

Cheers,

Auke

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
