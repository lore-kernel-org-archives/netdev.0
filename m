From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH -next 2/3] net: sched: remove AT INGRESS/EGRESS
Date: Fri, 15 May 2015 13:09:45 -0700
Message-ID: <20150515200944.GA8527@Alexeis-MacBook-Pro.local>
References: <1431679850-31896-1-git-send-email-fw@strlen.de>
 <1431679850-31896-3-git-send-email-fw@strlen.de>
 <20150515162319.GA8234@Alexeis-MBP.westell.com>
 <20150515172115.GK6179@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, daniel@iogearbox.net
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:36335 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934056AbbEOUJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 16:09:49 -0400
Received: by igbpi8 with SMTP id pi8so4279323igb.1
        for <netdev@vger.kernel.org>; Fri, 15 May 2015 13:09:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150515172115.GK6179@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 15, 2015 at 07:21:15PM +0200, Florian Westphal wrote:
> So, from ifb point of view it makes no difference, G_TC_FROM+AT_STACK
> causes skb to be dropped and IFB doesn't care about G_TC_AT() at all.

yes. your change is technically correct. It's not causing ifb regression,
but it removes information in a way that will be very hard to add it later.

> AT_STACK cannot even happen for the G_TC_AT case from looking at the
> code since dev_queue_xmit forces AT_EGRESS & rx sets AT_INGRESS.

yes, if we only consider ingress and egress hooks.
I want to use this stack/ingress/egress indication with socket filters.
If we make stack==egress, I would need to refactor this code all over again.
It's not broken today. You're doing this aliasing only two squeeze a bit.
That's why I'm saying keep the stack/ingress/egress flag as-is. It's useful.
