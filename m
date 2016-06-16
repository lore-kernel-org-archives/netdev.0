From: zyjzyj2000@gmail.com
Subject: [PATCH net-next v3 1/1] ixgbe: add fiber tranceiver plug/unplug notifier
Date: Fri, 17 Jun 2016 00:04:23 +0800
Message-ID: <1466093064-14027-1-git-send-email-zyjzyj2000@gmail.com>
To: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	donald.c.skidmore@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [111.193.78.174] ([111.193.78.174]:33309 "EHLO mail.zhuyj.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753945AbcFPQEc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jun 2016 12:04:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi, all

The changes are as below:

V3:
1.move the 2 variables from ixgbe_hw struct to ixgbe_adapter struct;

V2:
 1. Replace IXGBE_IDENTIFIER with IXGBE_ESDP;
 2. Replace plug interrupt with poll;
 3. Indicate the NICs that does not support to plug/unplug tranceiver as plugged;

 Hi, Don
 
 Thanks for your reply. I will try to explain your concerns.
 
 1. The ixgbe_sfp_detection_subtask function is driven by our master service task which isn't always running and doesn't always run at the same frequency.
 
 Sure. If we open the nic, the ixgbe_sfp_detection_subtask function will be run. The command "ip link set eth0 up" can open the nic. In this patch, the time precision is not the first. We can accept several seconds delay. So it is not important that the ixgbe_sfp_detection_subtask function can not run at the same frequency. 
 
 2. - Insertion/removal while the device is down.


 I made tests about this. When the device is down, there is no any interrupt and the ixgbe_sfp_detection_subtask function will not be run after the fiber tranceiver is plugged/unplugged.
 
 3. - Initial query when the driver is loaded.


 When the driver is loaded, the initial query will be sent. And the NETDEV_FIBER_TRANCEIVER_UNPLUG notifier will be sent if the fiber tranceiver is absent. Or else, the NETDEV_FIBER_TRANCEIVER_PLUG notifier will be sent. To 82598EB NIC that does not support plug/unplug fiber tranceiver, the notifier NETDEV_FIBER_TRANCEIVER_PLUG is sent.
 
 4. - Some modules aren't supported I'm not sure how you would want to there, still report the insertion to the stack, ignore it?


 Sure. From my tests, I think 82598EB does not support plug/unplug. And we treat the tranceiver as plugged in 82598EB. When the driver is loaded, the notifier NETDEV_FIBER_TRANCEIVER_PLUG is sent. And the status of the fiber tranceiver will not be changed in 82598EB
 
 5. - I've also recently added a crosstalk fix that your patch would not take in to consideration.


 Thanks a lot. I read your patch carefully. I do not think this patch is related with yours since this patch is only to check the absence of fiber tranceiver. It will not change anything. 


 If I am wrong, please correct me.
 
 BTW, your patch provides a better method to detect the absence of fiber tranceiver. Thanks.
 
 6. Some receive interrupts while others have to poll.


 I know. Maybe some NICs do not support interrupts. So poll is used to check the absence of fiber tranceiver. Soon I will send a new patch.
 
 The patch will be sent soon.
 Any reply is appreciated.
 
 Zhu Yanjun
