From: Mark Nipper <nipsy@bitgnome.net>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Fri, 31 Mar 2006 04:51:36 -0600
Message-ID: <20060331105135.GE25240@king.bitgnome.net>
References: <200603311057.07213.netdev@axxeo.de> <E1FPFkT-0002om-00@gondolin.me.apana.org.au> <20060331.013540.95485284.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@axxeo.de,
	jesse.brandeburg@intel.com, nipsy@bitgnome.net, jrlundgren@gmail.com,
	cat@zip.com.au, djani22@dynamicweb.hu, yoseph.basri@gmail.com,
	bb@kernelpanic.ru, mykleb@no.ibm.com, olel@ans.pl, michal@feix.cz,
	chris@scorpion.nl, netdev@vger.kernel.org,
	jesse.brandeburg@gmail.com, E1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060331.013540.95485284.davem@davemloft.net>
Sender: e1000-devel-admin@lists.sourceforge.net
Errors-To: e1000-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Id: netdev.vger.kernel.org

On 31 Mar 2006, David S. Miller wrote:
> He does not have TSO enabled, e1000 disables TSO when on a link speed
> slower than gigabit.
> 
> You'll see something like the following in your logs:
> 
> e1000: eth0: e1000_watchdog_task: 10/100 speed: disabling TSO

        Um...
---
$ uname -a
Linux king 2.6.16.1 #1 SMP Thu Mar 30 06:11:33 CST 2006 i686 GNU/Linux
$ dmesg | grep -i task
e1000: eth1: e1000_watchdog_task: NIC Link is Up 100 Mbps Full Duplex
$ ethtool -k eth1
Offload parameters for eth1:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: on
---

        I know for a fact the link is 100Mbps (other than the
output from the driver itself) and I have been bitten by the
assertion.

        I've been running the first patch for about the last 24
hours and have not seen any assertions yet (although they don't
occur that frequently on this server).  I'll be adding the
second, most recent patch in a bit and rebooting again.
Hopefully between the two of them, that will have fixed the
problem.

-- 
Mark Nipper                                                e-contacts:
832 Tanglewood Drive                                nipsy@bitgnome.net
Bryan, Texas 77802-4013                     http://nipsy.bitgnome.net/
(979)575-3193                      AIM/Yahoo: texasnipsy ICQ: 66971617

-----BEGIN GEEK CODE BLOCK-----
Version: 3.1
GG/IT d- s++:+ a- C++$ UBL++++$ P--->+++ L+++$ !E---
W++(--) N+ o K++ w(---) O++ M V(--) PS+++(+) PE(--)
Y+ PGP t+ 5 X R tv b+++@ DI+(++) D+ G e h r++ y+(**)
------END GEEK CODE BLOCK------

---begin random quote of the moment---
And if I close my mind in fear, please pry it open.
----end random quote of the moment----


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
