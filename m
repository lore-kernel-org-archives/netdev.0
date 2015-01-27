From: Yang Yingliang <yangyingliang@huawei.com>
Subject: A problem about ICMP packet-too-big message handler
Date: Tue, 27 Jan 2015 20:58:53 +0800
Message-ID: <54C78B8D.1070104@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:25909 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758854AbbA0M73 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 07:59:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

My kernel is 3.10 LTS.

I got a problem here about handling ICMP packet-too-big message.

Before sending a packet-too-big packet :

# ip -6 route list table local
local ::1 dev lo  metric 0 
local fe80:: dev lo  metric 0 
local fe80:: dev lo  metric 0 
local fe80:: dev lo  metric 0 
local fe80:: dev lo  metric 0 
local fe80:: dev lo  metric 0 
local fe80:: dev lo  metric 0 
local fe80::1 dev lo  metric 0 	//It  does not have expire value
local fe80::200:ff:fe00:0 dev lo  metric 0 
local fe80::200:ff:fe00:0 dev lo  metric 0 
local fe80::200:ff:fe00:0 dev lo  metric 0 
local fe80::200:ff:fe00:0 dev lo  metric 0 
local fe80::200:ff:fe00:2 dev lo  metric 0 
local fe80::5054:ff:fe12:3456 dev lo  metric 0


After sending a packet-too-big packet

ip -6 route list table local
local ::1 dev lo  metric 0 
local fe80:: dev lo  metric 0 
local fe80:: dev lo  metric 0 
local fe80:: dev lo  metric 0 
local fe80:: dev lo  metric 0 
local fe80:: dev lo  metric 0 
local fe80:: dev lo  metric 0 
local fe80::1 dev lo  metric 0  expires _597_  //It has expire value
local fe80::200:ff:fe00:0 dev lo  metric 0 
local fe80::200:ff:fe00:0 dev lo  metric 0 
local fe80::200:ff:fe00:0 dev lo  metric 0 
local fe80::200:ff:fe00:0 dev lo  metric 0 
local fe80::200:ff:fe00:2 dev lo  metric 0 
local fe80::5054:ff:fe12:3456 dev lo  metric 0

When time is up, I can't ping fe80::1 .
Is it ok or a bug ?

Regards,
Yang
