From: "=?KOI8-R?B?7MXPzsnEIODS2MXX?=" <leo@yuriev.ru>
Subject: [r8169] patch for RTL8102 (5 new MAC/PHY)
Date: Tue, 19 Aug 2008 17:45:07 +0400
Message-ID: <1f9da0830808190645o4ecf48b1i6f4d873db3c83e39@mail.gmail.com>
References: <1f9da0830808190642yacb2aacv6517e2bb86a3706@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Francois Romieu" <romieu@fr.zoreil.com>,
	"Leo Yuriev" <leo@yuriev.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f16.google.com ([209.85.217.16]:52325 "EHLO
	mail-gx0-f16.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751873AbYHSNpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 09:45:09 -0400
Received: by gxk9 with SMTP id 9so5014259gxk.13
        for <netdev@vger.kernel.org>; Tue, 19 Aug 2008 06:45:09 -0700 (PDT)
In-Reply-To: <1f9da0830808190642yacb2aacv6517e2bb86a3706@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

INTRO:
Few days ago I need to run Linux on Intel's D945GCLF board with
RTL8102. Driver from 2.6.26 oops on boot, but 2.6.27-rc2 seems
working. Unfortunately really it fails too. Not even, but in some
cases with influence of BIOS setting...

Late I found obsolete Realtek's driver
(http://downloadcenter.intel.com/Detail_Desc.aspx?agr=Y&ProductID=2916&DwnldID=16242&strOSs=39&OSFullName=Linux*&lang=eng).
It is a poor (IMHO) driver based on 2.6.18-version of r8169.c

Actual difference from the current r8169.c is in detection and "magic"
handle of the 5 new versions of RTL's MACs and corresponded PHY.

On Sunday I just pull some "magic" lines from Realtek to r8169, now my
D945GCLF board work fine in any cases :)

Not all "magic" from Realtek was pulled, few of them is really mad
(e.g. watchdog for loosing a PCI-config).

SUBJ:
If all agree, I will prepare for review a set of patches:
1) cosmetic: remark about supported chips (8168/8110/8111/8101/8102)
into KConfig and driver. Elsewhere it is not easy to find required
driver thru "make *config";
2) simple: by RTL8169 datasheet 'rx-missed' counter is 24-bits width,
but not 32;
3) simple: account dev->stats.rx_over_errors on RxFIFOOver and RxOverflow;
4) workaround: RTL8102 seems (sure) not have "rx-missed" (PCI-reg
0x4C) counter. So we should not account dev->stats.rx_missed_errors
like RTL8169;
5) big: a "magic" from Realtek's driver for RTL8102 (no any datasheet
are accessible/available);
