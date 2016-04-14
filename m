From: =?UTF-8?Q?Peter_Pal=c3=bach?= <Peter.Paluch@fri.uniza.sk>
Subject: [RFC] VLAN aux info for AF_PACKET available only with ETH_P_ALL
Date: Thu, 14 Apr 2016 17:17:34 +0200
Message-ID: <570FB48E.2060108@fri.uniza.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from castor.kis.fri.uniza.sk ([158.193.152.2]:41191 "EHLO
	mail.kis.fri.uniza.sk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755264AbcDNPRh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 11:17:37 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.kis.fri.uniza.sk (Postfix) with ESMTP id 86A38203045D
	for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 17:17:34 +0200 (CEST)
Received: from mail.kis.fri.uniza.sk ([127.0.0.1])
	by localhost (castor.kis.fri.uniza.sk [127.0.0.1]) (amavisd-new, port 10044)
	with LMTP id x5FTqY8d7b+s for <netdev@vger.kernel.org>;
	Thu, 14 Apr 2016 17:17:34 +0200 (CEST)
Received: from [192.168.110.11] (unknown [192.168.110.11])
	by mail.kis.fri.uniza.sk (Postfix) with ESMTPSA id 6BEA9203045C
	for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 17:17:34 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings,

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

As the VLAN tag is being stripped off the frame soon in the receive 
path, using PACKET_AUXDATA is the only way for an application over an 
AF_PACKET socket to know what VLAN did a particular frame arrive in; 
yet, the current behavior forces the application to listen to all 
received traffic to get the actual VLAN info.

Is this behavior intentional, or is this lack of VLAN info a bug? I am 
running vanilla Linux kernel v4.4.6.

Thanks!

Best regards,
Peter
