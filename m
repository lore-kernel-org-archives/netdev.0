From: =?ISO-8859-1?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
Subject: Re: [PATCH] Fix checksum bug for multicast/broadcast packets on postrouting
 hook
Date: Sat, 14 Feb 2004 21:07:14 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <402E71E2.1040508@kolumbus.fi>
References: <Xine.LNX.4.44.0402141318490.6128-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, Harald Welte <laforge@netfilter.org>,
        netdev@oss.sgi.com, Stephen Smalley <sds@epoch.ncsc.mil>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0402141318490.6128-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



James Morris wrote:

>This patch fixes a bug with with multicast/broadcast packets,
>Netfilter, and NICs which do hardware checksums.
>
>Outgoing multicast and broadcast packets are cloned prior to being fed
>into the postrouting hook and looped back.  A problem is caused when the
>shared packet data is modified by the netfilter core code when updating
>the checksum, but the skb->ip_summed field in the header of the original
>skb is not updated.  The NIC then tries to do a hardware checksum on an
>already correct checksum, and we end up transmitting the wrong thing.
>
>This bug stops things like DHCP from working, and was noted under SELinux
>which uses the postrouting hook alone.
>
>The proposed solution below is to copy the skb rather than clone it, to 
>ensure that the original and looped back packets are independent.
>
>Please review.
>
>(A similar problem seems to exist in the IPv6 code, although not 
>verified yet).
>
>
>- James
>

This is unneeded overhead for the common case. The right fix is to make 
sure the modifier (netfilter etc) makes the copy if needed. Actually, 
this is what skb_ip_make_writable() is doing.

--Mika
