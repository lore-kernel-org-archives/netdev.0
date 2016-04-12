From: =?UTF-8?Q?Peter_Pal=c3=bach?= <Peter.Paluch@fri.uniza.sk>
Subject: VLAN aux info for AF_PACKET available only with ETH_P_ALL
Date: Tue, 12 Apr 2016 16:40:20 +0200
Message-ID: <570D08D4.6040000@fri.uniza.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from castor.kis.fri.uniza.sk ([158.193.152.2]:47090 "EHLO
	mail.kis.fri.uniza.sk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756667AbcDLOuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 10:50:22 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.kis.fri.uniza.sk (Postfix) with ESMTP id 6AA412027948
	for <netdev@vger.kernel.org>; Tue, 12 Apr 2016 16:40:21 +0200 (CEST)
Received: from mail.kis.fri.uniza.sk ([127.0.0.1])
	by localhost (castor.kis.fri.uniza.sk [127.0.0.1]) (amavisd-new, port 10044)
	with LMTP id DdellYyG6qEA for <netdev@vger.kernel.org>;
	Tue, 12 Apr 2016 16:40:21 +0200 (CEST)
Received: from [192.168.110.11] (unknown [192.168.110.11])
	by mail.kis.fri.uniza.sk (Postfix) with ESMTPSA id 46C1A2002C61
	for <netdev@vger.kernel.org>; Tue, 12 Apr 2016 16:40:21 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings,

I am running vanilla Linux kernel v4.4.6.

When using AF_PACKET sockets with PACKET_AUXDATA socket option to access 
the VLAN TCI information of received frames, I have noticed that the 
VLAN information in struct tpacket_auxdata, namely,

- tp_vlan_tci
- tp_vlan_tpid
- TP_STATUS_VLAN_VALID and TP_STATUS_VLAN_TPID_VALID flags

is filled in only when the socket is bound to htons (ETH_P_ALL). If the 
socket is bound to any specific protocol, the VLAN information fields in 
struct tpacket_auxdata are set to 0 even if the datagram of the specific 
protocol was received in an 802.1Q-tagged frame.

Is this behavior intentional? If not, I would be honored to try to 
provide a patch but I am not well-versed in kernel internals so any 
guidance would be most appreciated.

Thanks!

Best regards,
Peter
