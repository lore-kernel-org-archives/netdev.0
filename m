From: Rask Ingemann Lambertsen <rask@sygehus.dk>
Subject: Re: problem in driver network code
Date: Fri, 7 Nov 2003 18:15:12 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031107181508.A1102@sygehus.dk>
References: <20031107083844.74787.qmail@web25202.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: francois donzet <fdonzet@yahoo.fr>
Content-Disposition: inline
In-Reply-To: <20031107083844.74787.qmail@web25202.mail.ukl.yahoo.com>; from fdonzet@yahoo.fr on Fri, Nov 07, 2003 at 09:38:44AM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Nov 07, 2003 at 09:38:44AM +0100, francois donzet wrote:
> 
> It seems to me that there is a problem ;). If i store
> in skb->csum a sum of all words of the packet data, it
>  will be unusable by tcp (the skb->csum doesn't
> contain the checksum of tcpheader plus data only, as
> the ipheader is part of the packet when the sum is
> computed)

That can be accounted for by the TCP code because the IP header is known to
the TCP code. IIRC, the pseudoheader is similiar to a real IP header, so it
may take just a few lines of code to make up for the difference, but I
haven't checked that.

What do you do with an IEEE 802.1q (VLAN) or 802.2 (LLC) packet? The VLAN
code in vlan_skb_recv() does not adjust skb->csum or skb->ip_summed. Neither
does the 802.2 code.

-- 
Regards,
Rask Ingemann Lambertsen
