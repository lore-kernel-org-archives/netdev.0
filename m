From: Anton Blanchard <anton@samba.org>
Subject: Re: Allow IP header alignment to be overriden
Date: Sat, 12 Jun 2004 00:08:43 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040611140843.GD27672@krispykreme>
References: <20040611012727.GA27672@krispykreme> <20040610223549.5e9ad025.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040610223549.5e9ad025.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 
> This transformation is not valid for a lot of drivers, that "2"
> in the reserve exists elsewhere in other calculations in the
> drivers.  For example, it is added to the RX skb allocation
> size.  Sometimes this '2' is there in non-trivial or hard to
> see ways (ie. it's implicitly in some DMA alignment value)
> 
> That's the only reason I'm against this patch.

Yeah I started converting all drivers across to skb_align and quickly
noticed that. We can instead convert drivers over as they are tested,
the Gbit and 10Gbit cards being the most important.

Ive tested the 2 10Gbit cards and one 1Gbit (e1000). I can test the
acenic and should be able to hunt down a sungem and tg3.

That leaves dl2K, myricom, ns83820, hamachi, yellowfin, r8169, and sk98lin
which can be converted across as needed.

Anton
