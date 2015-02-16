From: yzhu1 <Yanjun.Zhu@windriver.com>
Subject: Re: If bridge have no sub-interfaces, it's status may be still with
 'RUNNING'
Date: Mon, 16 Feb 2015 12:55:47 +0800
Message-ID: <54E17853.8070106@windriver.com>
References: <54DDCA99.4040401@windriver.com> <20150213133056.3944c13e@uryu.home.lan>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="------------010805050802080405080900"
Cc: netdev <netdev@vger.kernel.org>,
	"Wu, Kuaikuai" <Kuaikuai.Wu@windriver.com>,
	"Tao, Yue" <Yue.Tao@windriver.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:41644 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753664AbbBPEzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 23:55:40 -0500
In-Reply-To: <20150213133056.3944c13e@uryu.home.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------010805050802080405080900
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit

Hi, Stephen

Follow your advice, I made a new patch. This patch will turn off
carrier when a new bridge interface is created. Please comment on it.

Thanks a lot.
Zhu Yanjun
On 02/14/2015 02:30 AM, Stephen Hemminger wrote:
> On Fri, 13 Feb 2015 17:57:45 +0800
> yzhu1 <Yanjun.Zhu@windriver.com> wrote:
>
>> Hi, all
>>
>> I made this test on ubuntu 14.04 with kernel 3,19-rc7:
>>
>> 1. brctl addbr br0
>>
>> 2. ifconfig br0 up
>>
>> 3. ifconfig br0 (br0's status is with 'RUNNING')
>>
>> 4. brctl addif br0 eth0
>>
>> 5. brctl delif br0 eth0
>>
>> 6. ifconfig br0 (br0's status is without 'RUNNING')
>>
>> When there is no sub-interface, the flag "RUNNING" is missing after the
>> last sub-interface is removed.
>>
>> As such, should we keep "RUNNING" flag after the last sub-interface is
>> removed?
> This is intentional. If there are no active ports in bridge, then
> we want to tell applications that packets will go nowhere.
>
>


--------------010805050802080405080900
Content-Type: text/x-patch;
	name="0001-bridge-turn-off-carrier-when-the-bridge-is-created.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename*0="0001-bridge-turn-off-carrier-when-the-bridge-is-created.patc";
	filename*1="h"

>From e03af5263bcaeea15442601e2a9f65c6b582352b Mon Sep 17 00:00:00 2001
From: Zhu Yanjun <Yanjun.Zhu@windriver.com>
Date: Mon, 16 Feb 2015 12:45:36 +0800
Subject: [PATCH 1/1] bridge: turn off carrier when the bridge is created

When a bridge interface is created, there is no any sub interface
in it. In this case, the packets should not go to this bridge interface.
As such, carrier is turned off.

Suggested-by: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
---
 net/bridge/br_device.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index ffd379d..2d60474 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -394,4 +394,9 @@ void br_dev_setup(struct net_device *dev)
 	br_netfilter_rtable_init(br);
 	br_stp_timer_init(br);
 	br_multicast_init(br);
+
+	/* Shutdown bridge to avoid packets */
+	if (netif_carrier_ok(dev)) {
+		netif_carrier_off(dev);
+	}
 }
-- 
1.9.1


--------------010805050802080405080900--
