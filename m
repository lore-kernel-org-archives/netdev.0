From: =?iso-8859-1?q?francois=20donzet?= <fdonzet@yahoo.fr>
Subject: tracing a packet through the kernel stack
Date: Wed, 12 Nov 2003 16:37:08 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031112153708.41440.qmail@web25203.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi there,=20
i am trying to trace a packet which checksum has been
calculated in hardware (skb->ip_summed set to
CHECKSUM_HW) when it comes to the tcp layer.

I start with net/tcp_ipv4.c/tcp_v4_recv(). Here, there
is a call to tcp_v4_checksum_init(). If the call
returns a negative number, the packet is considered
invalid (checksum problem), and we go to the label
bad_packet.

i looked at tcp_v4_checksum_init() (in tcp_ipv4 too).

When skb->ip_summed  is set to CHECKSUM_HW, we first
set it to CHECKSUM_UNECESSARY, to indicate that
checksum hasn't to be computed later. Then we call
tcp_v4_check() function, with params including the
skb->len value, the source ip address,destination ip
address, and the value of skb->csum.

As far i know, skb->csum contains a sum of the entire
packet contents, computed by the hardware which
received the packet at the link layer level.

To sump up, We have :

tcp_v4_recv()-->tcp_v4_checksum_init()-->tcp_v4_check()-->csum_tcpudpmagi=
c().

When i look at the architecture dependent code
(asm-x86 for me) :

csum_tcpudp_magic is followed by csum_tcpudp_nofold,
and csum_fold calls.

In my understanding of the checksumming operations,
csum_tcpudp_magic() computes the pseudo header
checksum, based on the source adress, the destination
adress, the length of the packet and the ip protocol
of the packet (here tcp).=20

The initial sum to be add in contains the value of
skb->csum. My initial believing would have been that
(as someone suggests me after), some substractions
from the skb->csum (as pseudoheader contains fields in
ip header) would be made before checking the entire
TCP checksum.

But here, the skb->csum value is used "as is" in the
TCP checksum computation.

If you can give a little help, or tell me if i am
looking the wrong part of code, thanks.

___________________________________________________________
Do You Yahoo!? -- Une adresse @yahoo.fr gratuite et en fran=E7ais !
Yahoo! Mail : http://fr.mail.yahoo.com
