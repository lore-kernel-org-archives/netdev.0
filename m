From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [IPROUTE PATCH] iproute2: act_ipt fix xtables breakage on older
 versions.
Date: Thu, 25 Apr 2013 16:16:24 -0700
Message-ID: <20130425161624.68fa65b3@nehalam.linuxnetplumber.net>
References: <20130425220716.6520.94862.stgit@ahduyck-cp1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, Jamal Hadi Salim <jhs@mojatatu.com>,
	Hasan Chowdhury <shemonc@gmail.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:59428 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757432Ab3DYXQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 19:16:30 -0400
Received: by mail-pa0-f44.google.com with SMTP id bi5so2142485pad.17
        for <netdev@vger.kernel.org>; Thu, 25 Apr 2013 16:16:30 -0700 (PDT)
In-Reply-To: <20130425220716.6520.94862.stgit@ahduyck-cp1.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Apr 2013 15:07:16 -0700
Alexander Duyck <alexander.h.duyck@intel.com> wrote:

> In trying to build on a RHEL6.3 I ran into several build issues that are
> addressed in this patch.
> 
> The first is that xtables_options_xfrm only has 3 options.  It appears this is
> how this code was originally.  As such for the case where the version is less
> than 6 I am assuming it would be correct to maintain the original setup that
> only had 3 parameters being passed instead of 4.
> 
> I also ran into an issue with the define for __ALIGN_KERNEL not being present.
> I believe this may be due to the fact that __ALIGN_KERNEL was moved into a
> separate header from ALIGN after the uapi changes.  In order to just cover all
> of the bases I have moved the main definition for the macros into
> __ALIGN_KERNEL_MASK and __ALIGN_KERNEL and if ALIGN is also needed then it is
> just a direct redefine to __ALIGN_KERNEL.
> 
> Cc: Hasan Chowdhury <shemonc@gmail.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>


I want some feedback from Jamal and libxt netfilter experts.
This code has been fragile in the past.
