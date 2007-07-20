From: Richard MUSIL <richard.musil@st.com>
Subject: [GENETLINK]: Question: global lock (genl_mutex) possible refinement?
Date: Fri, 20 Jul 2007 14:52:39 +0200
Message-ID: <46A0B017.4080505@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s200aog13.obsmtp.com ([207.126.144.127]:40219 "EHLO
	s200aog13.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751312AbXGTNLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2007 09:11:22 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id ED472DAEC
	for <netdev@vger.kernel.org>; Fri, 20 Jul 2007 12:52:36 +0000 (GMT)
Received: from mail1.prg.st.com (mail1.prg.st.com [164.130.59.16])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id BEBEA4C021
	for <netdev@vger.kernel.org>; Fri, 20 Jul 2007 12:52:36 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I am currently trying to write a module which communicates with user space using NETLINK_GENERIC. This module (dev_mgr) manages virtual devices which are also supposed to use genetlink for communication with user space.

I want to do something like that:
dev_mgr <- receives message from user space to create new device
dev_mgr	inside 'doit' handler:
	1. creates device
	2. registers new genetlink family for the device
	3. returns family name and id to user

This should work similarly for device removal.

After few reboots I found out that 2. blocks on genl_mutex, since this mutex is already acquired when genl_register_family is called (by genl_rcv).

I do not see why registering new family (when processing message for another family) should be a problem. In fact from genl_lock and genl_trylock occurrence it seems that genl_mutex is mostly used for syncing access to family list and also for message processing.
Since I am not (yet) familiar enough with (ge)netlink internals I am asking:
Would it make sense to split the mutex into two, one for family list and one for messaging, so it would be possible to change families when processing the message?

Simple split could introduce possible danger of user removing family inside processing of the message for this particular family, but would this really be a danger?

--
Richard
