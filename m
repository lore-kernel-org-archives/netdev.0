From: "Ron Mercer" <ron.mercer@qlogic.com>
Subject: RE: New Qlogic qla3xxx NIC Driver v2.02.00k34 for upstream inclusion
Date: Fri, 23 Jun 2006 09:36:19 -0700
Message-ID: <0BB3E5E7462EEA4295BC02D49691DC07176938@AVEXCH1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "Linux Driver" <Linux-Driver@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pat.qlogic.com ([198.70.193.2]:64124 "EHLO avexch1.qlogic.com")
	by vger.kernel.org with ESMTP id S1751750AbWFWQgT convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 12:36:19 -0400
Content-class: urn:content-classes:message
To: "Jeff Garzik" <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff,

I will address all of your points in my next post. 

> 5) What is the point of using the hardware semaphore?  Is a firmware 
> competing with the device driver somehow, and its activities require 
> synchronization with the OS driver?

>From the body of my previous post:
- ql_wait_for_drvr_lock is used to protect resources that are shared 
  across the network and iSCSI functions.  This protection is mostly 
  during chip initialization and resets, but also include link 
  management.


The drvr_lock is to allow the iSCSI driver, iSCSI firmware, and the
network driver exclusive access to common points in the hardware.


> 12) For new drivers, we see additional work and little value for 
> maintained #ifdef'd NAPI and non-NAPI code paths.  Just pick the best 
> one (and justify that decision with sound technical rationale).

I am not sure what sound technical rationale would apply here.  NAPI has
better thoughput and non-NAPI has lower latency.  However, I will pick
one and remove the other.





