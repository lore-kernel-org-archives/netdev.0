From: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
Subject: Invalid truesize messages since 2.6.25
Date: Fri, 26 Sep 2008 19:53:45 +0200
Message-ID: <3C59DB883F7B0B4D8096010D45ACCD13C73CAE@exch.facton.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.facton.com ([83.236.152.122]:39269 "EHLO alpha.facton.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752335AbYIZSDo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2008 14:03:44 -0400
Received: from exch.facton.local (exch [192.168.200.5])
	by alpha.facton.com (8.13.8/8.13.8/FACTON) with ESMTP id m8QHriQp015178
	for <netdev@vger.kernel.org>; Fri, 26 Sep 2008 19:53:44 +0200
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I did some more investigations and can reproduce it now in a simple way:

I take my tg3 device into promiscuous mode and capture ESP packets:
Just "tcpdump -i eth1 esp" and ping 4 times through the IPSEC tunnel to
generate ESP traffic, after that dmesg shows

device eth1 entered promiscuous mode
SKB BUG: Invalid truesize (336) len=134, sizeof(sk_buff)=208
SKB BUG: Invalid truesize (336) len=134, sizeof(sk_buff)=208
SKB BUG: Invalid truesize (336) len=134, sizeof(sk_buff)=208
SKB BUG: Invalid truesize (336) len=134, sizeof(sk_buff)=208
device eth1 left promiscuous mode

Daniel

----------
Since 2.6.25 we rarely see these messages:

SKB BUG: Invalid truesize (408) len=198, sizeof(sk_buff)=216

Yesterday I saw it the first time after a runtime of one week with
2.6.26.
The box is web server / IPSEC gateway.
Obviously nothing seems to be affected by the message but <= 2.6.24 no
messages appeared.

Daniel
