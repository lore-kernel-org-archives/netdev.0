From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Packetlost when "tc qdisc del dev eth0 root"
Date: Tue, 15 Jan 2008 14:10:47 +0300
Message-ID: <478C94B7.3070503@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:49791 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130AbYAOLK4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 06:10:56 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.bigtelecom.ru (Postfix) with ESMTP id A5218A6C300
	for <netdev@vger.kernel.org>; Tue, 15 Jan 2008 14:10:54 +0300 (MSK)
Received: from mail.bigtelecom.ru ([127.0.0.1])
	by localhost (mail.bigtelecom.ru [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id cOVq9Az4HAFa for <netdev@vger.kernel.org>;
	Tue, 15 Jan 2008 14:10:48 +0300 (MSK)
Received: from [87.255.0.131] (slavon.bigtelecom.ru [87.255.0.131])
	by mail.bigtelecom.ru (Postfix) with ESMTP id 7C833A6C1A7
	for <netdev@vger.kernel.org>; Tue, 15 Jan 2008 14:10:48 +0300 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all. Have packetlost when do "tc qdisc del dev eth0 root".

look:

slavon ~ # ping -f 87.255.1.134
PING 87.255.1.134 (87.255.1.134) 56(84) bytes of data.
.
.....................................................................................................................................................................................................................................................................
.
--- 87.255.1.134 ping statistics ---
60811 packets transmitted, 60544 received, 0% packet loss, time 39528ms
rtt min/avg/max/mdev = 0.203/0.579/3227.655/13.124 ms, pipe 219, 
ipg/ewma 0.650/2.197 ms

Its normal?
Maybe if tc do changes - need create second queue (hash of rules or how 
you named it?) and do changes at it. Then replace old queue rules by 
created new.
Logic -
1. Do snapshot
2. Do changes in shapshot
3. All new packets go to snapshot
4. If old queue not have packets - delete it.
5. Snapshot its default.

Thanks for answers.
Slavon.

