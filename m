From: =?iso-8859-1?q?francois=20donzet?= <fdonzet@yahoo.fr>
Subject: problem in driver network code
Date: Fri, 7 Nov 2003 09:38:44 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031107083844.74787.qmail@web25202.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi all

I am writing my own ethernet driver, and i have a
little question on checksum offloading :

I am trying to understand the role of skb->csum. I've
read some code, and see that it is filled (for example
in e100 code) by the sum of all words excepting the
ethernet II header.

The fact is, on an input path, if CHECKSUM_HW is set,
TCP uses skb->csum to verify the complete checksum
(adding the pseudo header one).

It seems to me that there is a problem ;). If i store
in skb->csum a sum of all words of the packet data, it
 will be unusable by tcp (the skb->csum doesn't
contain the checksum of tcpheader plus data only, as
the ipheader is part of the packet when the sum is
computed)

What do i miss ? I think the skb->csum MUST at one
point contain only a sum on tcpheader+data.

___________________________________________________________
Do You Yahoo!? -- Une adresse @yahoo.fr gratuite et en fran=E7ais !
Yahoo! Mail : http://fr.mail.yahoo.com
