From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: d80211: ieee80211_hw handlers in atomic context
Date: Wed, 4 Oct 2006 19:22:38 +0200
Message-ID: <200610041922.39079.IvDoorn@gmail.com>
References: <4523DA7D.2080604@web.de> <20061004183804.748706d6@griffin.suse.cz> <4523E69C.1090408@web.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:64967 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S964862AbWJDRXd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 13:23:33 -0400
Received: by nf-out-0910.google.com with SMTP id x30so547541nfb
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2006 10:23:32 -0700 (PDT)
To: Jan Kiszka <jan.kiszka@web.de>
In-Reply-To: <4523E69C.1090408@web.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> > On Wed, 4 Oct 2006 18:34:57 +0200, Ivo van Doorn wrote:
> >> You could replace the timer with a workqueue, the original patch
> >> also did that, so I think it would be good enough this time as well. :)
> > 
> > Yes, the timing isn't required to be precise here.
> 
> Ok, I'm not promising success and I'm going to duck immediately if
> someone else feels like working on it, but I could try to patch in this
> direction.

If you need testing of the patch for a slightly larger audience,
you can send it to me and I'll place it in the rt2x00 CVS tree which contains
a copy of the current dscape stack for backwards compatibility with older kernels.

> Now there just remains my precautious question if there are other
> services in the ieee_80211_hw interface that may conflict with sleeping
> USB drivers. What about specifying the possible contexts in
> include/net/d80211.h?

Well another point of concern for me is the TSF handling, those handlers are called
from interrupt context as well, and also deliver problems for the USB drivers in case
of adhoc mode.

Ivo
