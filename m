From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] mac80211: Fix TX after monitor interface is converted to managed
Date: Thu, 04 Oct 2007 14:31:26 -0700
Message-ID: <ada4ph6bm8h.fsf@cisco.com>
References: <20071004113343.552139D502B@zog.reactivated.net>
	<200710041706.06182.mb@bu3sch.de>
	<20071004151956.GE6037@tuxdriver.com>
	<200710041311.37997.flamingice@sourmilk.net>
	<20071004181516.GH6037@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mb@bu3sch.de>, Daniel Drake <dsd@gentoo.org>,
	johannes@sipsolutions.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1-in.cisco.com ([171.71.176.70]:49959 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757296AbXJDVbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 17:31:34 -0400
In-Reply-To: <20071004181516.GH6037@tuxdriver.com> (John W. Linville's message of "Thu, 4 Oct 2007 14:15:16 -0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > Programming with assertions (and BUG_ON is a form of that) is
 > generally a good practice.  Almost any book or other source on
 > good programming practices will agree.  Yes, it can be overdone.
 > But I don't really think that is the case here, since the check is
 > relatively inexpensive and the consequence should it ever *somehow*
 > happen could be a something wierd (crash, corruption, etc) w/o any
 > other indication of what occured.

The problem with BUG_ON is that it kills the whole system.  So every
time you add a BUG_ON into code, you have to weigh whether the problem
you detected is so severe that the right response is to panic.  For
example, I can see panicking on something fundamental like corrupted
page tables.  However I would submit that the wireless stack should
*never* use BUG_ON -- printing a warning and trying to limp on seems
preferable to me.

 - R.
