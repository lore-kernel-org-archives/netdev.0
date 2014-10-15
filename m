From: Bokhan Artem <art@eml.ru>
Subject: performance of two 82599 nics at a host
Date: Wed, 15 Oct 2014 17:52:23 +0700
Message-ID: <543E51E7.3020206@eml.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout24.ngs.ru ([195.19.71.7]:56061 "EHLO smtpout.ngs.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751118AbaJOKwd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Oct 2014 06:52:33 -0400
Received: from [192.168.44.12] (nsk-ws423.ngs.local [192.168.44.12])
	(Authenticated sender: art@eml.ru)
	by mail.ngs.ru (smtp) with ESMTPA id 36A392006DC
	for <netdev@vger.kernel.org>; Wed, 15 Oct 2014 17:52:23 +0700 (NOVT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, everyone.

I have two 82599 nics connected to different numa nodes. Each nic can 
recieve up to 12Mpps 64-byte packets.

But when I send traffic to both nics only 5Mpps+5Mpps can be recieved.

May someboby help if it's driver, kernel or hardware bottleneck?

Configuration:

2 x E5-2667 v2@3.30GHz
3.14.19 kernel, 3.22.3 ixgbe
8 queues at each nic with affinity set

NIC1
--pkt/eth2- --pkt/eth5-
#recv #send:#recv #send
    0     0 :12.6M    0
    0     0 :12.7M    0
    0     0 :12.7M    0
    0     0 :12.7M    0
    0     0 :12.7M    0

NIC2
--pkt/eth2- --pkt/eth5-
#recv #send:#recv #send
12.7M    0 :   0     0
12.7M    0 :   0     0
12.6M    0 :   0     0
12.7M    0 :   0     0
12.6M    0 :   0     0

both
--pkt/eth2- --pkt/eth5-
#recv #send:#recv #send
5099k    0 :5758k    0
5467k    0 :5325k    0
5050k    0 :5432k    0
5206k    0 :5133k    0
5162k    0 :5164k    0
