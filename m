From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH]: was Re: LLTX and netif_stop_queue
Date: Thu, 20 Jan 2005 13:41:35 -0800
Message-ID: <20050120134135.567e1cee.davem@davemloft.net>
References: <5cac192f0412230110628749e3@mail.gmail.com>
	<41CAF444.3000305@trash.net>
	<5cac192f04122408102129af43@mail.gmail.com>
	<1104240717.1100.66.camel@jzny.localdomain>
	<5cac192f0501021530672a908a@mail.gmail.com>
	<1104764660.1048.578.camel@jzny.localdomain>
	<52brc68q05.fsf@topspin.com>
	<5cac192f05010308414a25b548@mail.gmail.com>
	<527jmu8nbw.fsf@topspin.com>
	<5cac192f0501030907c755135@mail.gmail.com>
	<20050103171227.GD7370@esmail.cup.hp.com>
	<1104812294.1085.53.camel@jzny.localdomain>
	<20050119144711.3fdd3d93.davem@davemloft.net>
	<20050119151853.259de49a@dxpl.pdx.osdl.net>
	<20050119164640.6c67bdfa.davem@davemloft.net>
	<52r7kgu5n5.fsf@topspin.com>
	<20050119230526.393a5184.davem@davemloft.net>
	<1106229084.5812.40.camel@tsc-6.cph.tpack.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: roland@topspin.com, shemminger@osdl.org, hadi@cyberus.ca, iod00d@hp.com,
        eric.lemoine@gmail.com, netdev@oss.sgi.com, ak@suse.de,
        openib-general@openib.org, kaber@trash.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
In-Reply-To: <1106229084.5812.40.camel@tsc-6.cph.tpack.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 20 Jan 2005 14:51:25 +0100
Tommy Christensen <tommy.christensen@tpack.net> wrote:

> A lot more serious is the fact that ->tx_timeout() and
> ->hard_start_xmit() are no longer allowed to do this:

Sigh, there are even more issues.  Now dev_kfree_skb()
is illegal in ->hard_start_xmit() because interrupts are
disabled, and there are many such cases in the simpler
net drivers.

I think we might need to revert the change over to IRQ
disabling dev->xmit_lock and rethink this.  This is just too
much fallout.
