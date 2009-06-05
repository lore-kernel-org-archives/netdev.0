From: Radha Mohan <radhamohan_ch@yahoo.com>
Subject: behavior of TSO in kernel
Date: Fri, 5 Jun 2009 20:09:10 +0530 (IST)
Message-ID: <340578.72366.qm@web94815.mail.in2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: radhamohan_ch@yahoo.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from n5-vm1.bullet.mail.in.yahoo.com ([202.86.4.130]:47944 "HELO
	n5-vm1.bullet.mail.in.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755696AbZFEOpZ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Jun 2009 10:45:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi all,

I have an ethernet driver with TSO, SG, IP_CSUM=A0features enabled. I a=
m using linux-2.6.15 kernel. The MTU is set to 9014. It seems the drive=
r is getting skbs of only 9014 bytes length even though the application=
 is able to write some 64KB at a time.=20

Why is TCP layer doing the segmentation when we said TSO is enabled by =
giving NETIF_F_TSO?

I saw tcp_sendmsg() function, and found that never an skb->len can be m=
ore than 12K since there is a check=A0that if it exceeds "mss_now" then=
=A0either tcp_push_one() or tcp_push()=A0is called. If=A0I further=A0se=
e the tcp_push_one() function, there we calculate the "limit" and furth=
er=A0trim the skb->len in tso_fragment().

In another function, tcp_write_xmit() also similar behaviour is present=
=2E

What I do not understand is why should TCP layer=A0do all these in soft=
ware=A0when there is TSO in hardware? Why can't a driver get a bigger p=
acket of say 64K or something larger than current=A0MSS=A0assuming ther=
e is enough window for sending it?

I have briefly checked 2.6.24 kernel but here also it is the same.=20


-- Mohan


      Explore and discover exciting holidays and getaways with Yahoo! I=
ndia Travel http://in.travel.yahoo.com/

