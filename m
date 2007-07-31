From: Unai Uribarri <unai.uribarri@optenet.com>
Subject: Disabling timestamps on AF_PACKET sockets
Date: Tue, 31 Jul 2007 18:24:14 +0200
Message-ID: <46AF622E.30104@optenet.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000009070402070202040602"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-mad.optenet.com ([213.27.232.70]:58999 "EHLO
	mta-mad.optenet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762632AbXGaQwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2007 12:52:51 -0400
Received: from mta-mad (localhost [127.0.0.1])
	by mailfilter.optenet.com (Postfix) with ESMTP id D5DAC81B55
	for <netdev@vger.kernel.org>; Tue, 31 Jul 2007 18:24:14 +0200 (CEST)
Received: from [192.168.3.29] (unknown [192.168.3.29])
	by smtp.optenet.com (Postfix) with ESMTP id 7085481B55
	for <netdev@vger.kernel.org>; Tue, 31 Jul 2007 18:24:14 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000009070402070202040602
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hello,

I want to capture huge amounts of packets without timestamps, since the
machine the program is running on has a very slow clock that only yields
200,000 timestamps per second and uses 70% of CPU. But tpacket_rcv
reenables the timestamps every time it receives a packet at af_packet.c:643

if (skb->tstamp.tv64 == 0) {
	__net_timestamp(skb);
	sock_enable_timestamp(sk);
}

I suppose that a patch that just removes that four lines won't be
accepted, since breaks an userspace interface. Isn't it?

So I've tried to enable timestamp when you setup the ring (to not affect
other programs) and disabling it latter from user space clearing the
SO_TIMESTAMP option. But it doesn't work, since timestamps can't be
disabled until the socket is closed.

If enabling SO_TIMESTAMP socket option sets SOCK_RCVTSTAMP and calls
sock_enable_timestamp, why disabling it just clears SOCK_RCVTSTAMP and
don't call sock_disable_timestamp?

Thanks.


--------------000009070402070202040602
Content-Type: text/x-vcard; charset=utf-8;
 name="unai.uribarri.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="unai.uribarri.vcf"

begin:vcard
fn;quoted-printable:Unai Uribarri Rodr=C3=ADguez
n;quoted-printable:Uribarri Rodr=C3=ADguez;Unai
org:Optenet;Research & Development
adr;quoted-printable;quoted-printable:Calle Jos=C3=A9 Echegaray 8;;Parque Empresarial Alvia;Las Rozas;Madrid;28232;Espa=C3=B1a
email;internet:unai.uribarri@optenet.com
tel;work:+34 902 154 604
tel;home:+34 913 575 433
tel;cell:+34 609 54 91 61
x-mozilla-html:TRUE
url:http://www.optenet.com
version:2.1
end:vcard


--------------000009070402070202040602--

