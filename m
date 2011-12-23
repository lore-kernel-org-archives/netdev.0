From: Xi Wang <xi.wang@gmail.com>
Subject: Re: [PATCH v2] rps: fix insufficient bounds checking in store_rps_dev_flow_table_cnt()
Date: Fri, 23 Dec 2011 00:49:21 -0500
Message-ID: <84179C81-7C33-4B2E-8B9C-A180E4B679BD@gmail.com>
References: <1324493459-19764-1-git-send-email-xi.wang@gmail.com> <4EF3BEBA.4040402@gmail.com> <1324613414.2674.2.camel@edumazet-laptop> <C0DC969A-A32B-4CC8-B565-FF741E9D75DA@gmail.com> <1324616007.2674.8.camel@edumazet-laptop> <ACB00AE8-CFEF-4535-9242-1B5C44F05C13@gmail.com> <1324617390.2674.13.camel@edumazet-laptop>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:38145 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042Ab1LWFtZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 00:49:25 -0500
Received: by ghbg21 with SMTP id g21so364270ghb.19
        for <netdev@vger.kernel.org>; Thu, 22 Dec 2011 21:49:25 -0800 (PST)
In-Reply-To: <1324617390.2674.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Dec 23, 2011, at 12:16 AM, Eric Dumazet wrote:
> 32 bit truncation _is_ a bound checking problem too.
> 
> Really, mixing INT_MAX / ULONG_MAX is ugly, this should had ring a bell
> when writing such hard to read code.
> 
> You cannot claim to give more range to 64bit platform, yet not spotting
> the 32bit truncation issue.
> 
> When fixing a bug, its always a good thing to look things around, and
> try to check the whole function.

Okay, seems like we are talking about two different issues here.

1) the truncation of "count" on 64-bit platform.

I don't mind if the user shoots himself in the foot by setting a
large or invalid rps_flow_cnt, as long as the kernel is not affected.
I do agree with you that the kernel could be more friendly and
reject the value rather than picking up part of it.  To be nicer
the kernel may even want to reject something like "123abc" that
simple_strtoul() would accept.  I am happy to see another patch
fixing that.

2) the bounds checking of the vmalloc() size on 32-bit platform.

I agree that the two checks are ugly. ;-)  Do you want to use INT_MAX
in both checks, or do you have something more elegant in mind?

- xi
