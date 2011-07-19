From: Vikas Aggarwal <vik.reck@gmail.com>
Subject: ICMP Redirect not working
Date: Mon, 18 Jul 2011 19:02:22 -0700
Message-ID: <CAOid5F9TfViKNvZQZ2HZfW8-iJLFxAZvWq+yhp964cM5m_Nx7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:46727 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977Ab1GSCCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 22:02:23 -0400
Received: by pvg12 with SMTP id 12so3469729pvg.19
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2011 19:02:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,
Seems there is a problem with ICMP Redirect handling in linux kernel
(icmp.c/icmp_redirect() ?). I tried testing against  linux kernels
2.6.32.13  and  2.6.23.1-42.

Description:
1) A host sends ICMP echo request to linux based gateway.
2) ICMP redirect is sent by linux gateway  in response to ICMP request.
3) But instead of  copying exactly the same  Internet header of original ICMP
request into ICMP redirect response -
    a) Linux IP stack incorrectly first decrements the TTL (0x40 --> 0x3F)
    b) Then recalculates the checksum to 0x2387
4) This results in wrong ICMP redirect response from linux gateway to the  host.

14:33:58.195347 0:14:c1:f:b:ee 0:f:b7:10:77:a6 ip 78: 172.16.0.10 >
172.17.0.11: icmp: echo request (ttl 64, id 0, len 64)
                   4500 0040 0000 0000 4001 2287 ac10 000a
                   ac11 000b 0800 e535 0001 0000 4175 746f
                   6d61 7465 6420 4e65 7477 6f72 6b20 5661
                   6c69 6461 7469 6f6e 204c 6962 7261 7279

14:33:58.195443 0:f:b7:10:77:a6 0:14:c1:f:b:ee ip 106: 172.16.0.1 >
172.16.0.10: icmp: redirect 172.17.0.11 to host 172.16.0.11 for 172.16.0.10 >
172.17.0.11: icmp: echo request (ttl 63, id 0, len 64) [tos 0xc0]  (ttl 64, id
14608, len 92)
                   45c0 005c 3910 0000 4001 e8a5 ac10 0001
                   ac10 000a 0501 4ee3 ac10 000b 4500 0040
                   0000 0000 3f01 2387 ac10 000a ac11 000b
                   0800 e535 0001 0000 4175 746f 6d61 7465
                   6420 4e65 7477 6f72 6b20 5661 6c69 6461
                   7469

Or otherwise please help me understand why host will not like the
above ICMP redirect response from the linux gateway.

RFC 792 : Page 11
Redirect Message
    0                   1                   2                   3
    0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |     Type      |     Code      |          Checksum             |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                 Gateway Internet Address                      |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |      Internet Header + 64 bits of Original Data Datagram      |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

regards
Vikas Aggarwal
