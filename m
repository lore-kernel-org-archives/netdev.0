From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] acx100 inclusion in mainline; generic 802.11 stack
Date: Mon, 6 Sep 2004 23:47:01 -0700
Sender: acx100-devel-admin@lists.sourceforge.net
Message-ID: <20040906234701.511a8940.davem@davemloft.net>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua>
	<757AB580-0030-11D9-9224-000A95AD0668@errno.com>
	<20040906182328.08faf843.davem@davemloft.net>
	<200409062132.49356.sam@errno.com>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: vda@port.imtp.ilyichevsk.odessa.ua, jgarzik@pobox.com,
 netdev@oss.sgi.com, acx100-devel@lists.sourceforge.net,
 jt@bougret.hpl.hp.com, jkmaline@cc.hut.fi, prism54-devel@prism54.org
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: Sam Leffler <sam@errno.com>
In-Reply-To: <200409062132.49356.sam@errno.com>
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

On Mon, 6 Sep 2004 21:32:49 -0700
Sam Leffler <sam@errno.com> wrote:

> Actually, this is the first time you've said anything to me about this code.  

I do remember telling you how much I was against this element of
your design.  At the time, you were not willing to rearchitect things
and you were in a sort-of bug-fix only mode.

> Perhaps you can point me at a description of what a "true network stack" means 
> to you.

It means passing the 802.11 protocol packets into the networking
just like any other type of packet, via netif_rx() or netif_receive_skb().
Creating an ETH_P_80211 protocol type and registering the stack via
dev_add_pack() just like any other real protocol layer does.

Then responses generated in that 802.11 stack need to feed packets back
out to the network via the normal and usual methods of transmitting
packets in the networking, namely dev_queue_xmit().

That is exactly what my shell protocol layer does, and it is exactly
how a real 802.11 soft stack should be implemented and operate.


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
