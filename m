From: =?ISO-8859-1?Q?Dennis_J=F8rgensen?= <postmaster@q.nospam.kampsax.k-net.dk>
Subject: Trivial fix for wrong error message from icmp.c (2.6.0-test4)
Date: Thu, 04 Sep 2003 02:26:42 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F5686C2.6090600@q.nospam.kampsax.k-net.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello


I see this message a lot in my logs:

192.38.215.157 sent an invalid ICMP type 11, code 0 error to a=20
broadcast: 192.38.215.255 on eth0

but thats my own ip, the following fix makes 2.6.0-test4 report the same=20
ip as 2.4.20 did.

Should I post this somewhere else/to someone else, please let me know, I=20
couldn't find a FAQ for the list.


Regards

  Dennis J=F8rgensen
 (not on the list)


--- linux-2.6.0-test4.org/net/ipv4/icmp.c       2003-08-28=20
01:13:59.000000000 +0200
+++ linux-2.6.0-test4/net/ipv4/icmp.c   2003-08-28 02:12:56.000000000 +02=
00
@@ -661,7 +661,7 @@
                        printk(KERN_WARNING "%u.%u.%u.%u sent an invalid=20
ICMP "
                                            "type %u, code %u "
                                            "error to a broadcast:=20
%u.%u.%u.%u on %s\n",
-                              NIPQUAD(iph->saddr),
+                              NIPQUAD(skb->nh.iph->saddr),
                               icmph->type, icmph->code,
                               NIPQUAD(iph->daddr),
                               skb->dev->name);
