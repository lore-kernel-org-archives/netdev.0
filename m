From: <wyb@topsec.com.cn>
Subject: is it useful testing __LINK_STATE_RX_SCHED in dev_close()?
Date: Wed, 21 Nov 2007 09:40:16 +0800
Message-ID: <200711210142.AYF83693@topsec.com.cn>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.topsec.com.cn ([202.99.27.222]:56218 "EHLO
	mail1.topsec.com.cn" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676AbXKUBp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 20:45:28 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

cpu0 calling netif_rx_schedule_prep(), cpu1 calling dev_close():

cpu0: testing __LINK_STATE_START, already set
cpu1: clear__LINK_STATE_START
cpu1: testing __LINK_STATE_RX_SCHED, not set
cpu0: set __LINK_STATE_RX_SCHED
cpu0: enter net poll, ...

when cpu1 return from dev_close(),__LINK_STATE_RX_SCHED is still set, the
testing maybe of no use.



