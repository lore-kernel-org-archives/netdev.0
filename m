From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: pppoe and receive checksum offload
Date: Mon, 28 Feb 2005 12:21:30 +0300
Message-ID: <20050228092130.GA26076@yakov.inr.ac.ru>
References: <20050224155906.73890361@dxpl.pdx.osdl.net> <20050227202011.5ccefb22.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, mostrows@speakeasy.net,
        kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050227202011.5ccefb22.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> Changing or expanding the link level headers should only mess
> up the hw checksum if you are using CHECKSUM_HW, is that what
> your skge driver is using?

Well, even if this driver uses CHECKSUM_UNNECESSARY, the bug is still
apparently present for another devices which use CHECKSUM_HW.

Actually, the bug is in ppp_input(). It is responsible for setting correct
ip_summed before doing netif_rx(). It could even optimize subtracting
checksum of stripped ppp header from ip_summed (f.e. ipgre_rcv() do this)

But suggested fix is still correct. Unless there are another users of
ppp_input() with the same problem.

Alexey
