From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm][v2] ratelimit rewrite
Date: Tue, 6 May 2008 12:24:23 -0700
Message-ID: <20080506122423.051b4254.akpm@linux-foundation.org>
References: <20080506022558.GA2904@darkstar.te-china.tietoenator.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: paulmck@us.ibm.com, joe@perches.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dave Young <hidave.darkstar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40424 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757194AbYEFTbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 15:31:05 -0400
In-Reply-To: <20080506022558.GA2904@darkstar.te-china.tietoenator.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 6 May 2008 10:25:58 +0800
Dave Young <hidave.darkstar@gmail.com> wrote:

> [Fixed a macro error found by davem, added more changes description.]
> 
> ---
> All ratelimit user use same jiffies and burst params, so some messages
> (callbacks) will be lost.
> 
> For example:
> a call printk_ratelimit(5 * HZ, 1)
> b call printk_ratelimit(5 * HZ, 1) before the 5*HZ timeout of a, then b will
> will be supressed.
> 
> Changes:
> 1. rewrite __ratelimit, and use a ratelimit_state as parameter.
>    Thanks for hints from andrew.
> 2. change WARN_ON_SECS to WARN_ON_RATELIMIT, update rcupreempt.h
> 3. remove __printk_ratelimit
> 4. use __ratelimit in net_ratelimit

I rebased this on top of mainline+linux-next+mm-stuff.  I'll drop
add-warn_on_secs-macro.patch and use-warn_on_secs-in-rcupreempth.patch
