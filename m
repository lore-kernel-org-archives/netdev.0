From: Amit Virdi <amit.virdi@st.com>
Subject: Testing IRDA device driver
Date: Wed, 13 Apr 2011 12:10:20 +0530
Message-ID: <4DA54554.7020500@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:58053 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751998Ab1DMGkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 02:40:37 -0400
Received: from zeta.dmz-ap.st.com (ns6.st.com [138.198.234.13])
	by beta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 23CFEC0
	for <netdev@vger.kernel.org>; Wed, 13 Apr 2011 06:40:23 +0000 (GMT)
Received: from Webmail-ap.st.com (eapex1hubcas2.st.com [10.80.176.10])
	by zeta.dmz-ap.st.com (STMicroelectronics) with ESMTP id C21178F8
	for <netdev@vger.kernel.org>; Wed, 13 Apr 2011 06:40:23 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

For the past few days I've been trying to test a driver that I've 
written for DICE Fast IrDA controller. As per my requirements, I need to 
use IrCOMM as the upper layer.

I'm using the same kernel image on the both the boards. When I run 
irattach on either of the boards I can see discovery protocol being 
initiated and completing successfully (cat /proc/net/irda/discovery 
giving output with other ends's device's MAC address as the daddr) but 
I'm struggling to test the driver further.

I've observed that the discovery request/response sequence goes on for 5 
minutes. After this, the discovery process stops. On the master side, I 
could see no IrLAP frame being sent/received and also the output of cat 
/proc/net/irda/discovery is NULL. However, on the slave side, the cat 
/proc/net/irda/discovery output shows the master side!!

If I run irattach on the slave side also, no DISCOVERY message is 
exchanged and then, the output of slave side also doesn't show anything.

Sometimes, I start getting log "IrLAP, no activity on link!" and then 
ircomm_close() API is called from within the stack.

If, I try to run getty on /dev/ircomm0, it does not work!

If I try to transfer data using
	echo "1234567890" > /dev/ircomm0
on the master side, and
	cat /dev/ircomm0
on the slave side, I can see SNRM command, UA response, RR command, 
IrLMP connect/disconnect etc. However, the data transfer actually didn't 
happen. I cannot see the string "1234567890" on the slave side.

Please suggest what I'm missing/doing wrong. I need to transfer data 
from one device to another to complete the testing. I shall be very much 
thankful for suggestions/advice.

Thanks n Regards
Amit Virdi
