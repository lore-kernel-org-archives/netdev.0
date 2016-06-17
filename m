From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH resend] net: sock: Add option for memory optimized hints.
Date: Fri, 17 Jun 2016 09:03:57 -0700
Message-ID: <1466179437.7945.214.camel@edumazet-glaptop3.roam.corp.google.com>
References: <57640204.9070300@sonymobile.com>
	 <1466172860.7945.212.camel@edumazet-glaptop3.roam.corp.google.com>
	 <57640BA7.8010304@sonymobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "open list:PTP HARDWARE CLOCK SUPPORT" <netdev@vger.kernel.org>
To: peter enderborg <peter.enderborg@sonymobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33671 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751873AbcFQQEA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 12:04:00 -0400
Received: by mail-pa0-f66.google.com with SMTP id ts6so6076260pac.0
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 09:04:00 -0700 (PDT)
In-Reply-To: <57640BA7.8010304@sonymobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-06-17 at 16:39 +0200, peter enderborg wrote:
> On 06/17/2016 04:14 PM, Eric Dumazet wrote:
> > On Fri, 2016-06-17 at 15:58 +0200, peter enderborg wrote:
> >> From: Peter Enderborg <peter.enderborg@sonymobile.com>
> >>
> >> When sending data the socket allocates memory for
> >> payload on a cache or a page alloc. The page alloc
> >> then might trigger compation that takes long time.
> >> This can be avoided with smaller chunks. But
> >> userspace can not know what is the right size for
> >> the smaller sends. For this we add a SIZEHINT
> >> getsocketopt where the userspace can get the size
> >> for send that will fit into one page (order 0) or
> >> the max for a slab cache allocation.
> >
> > For which kind of sockets exactly you hit a problem ?
> >
> > Sorry, this patch is probably not helping in any way.
> >
> It is mainly for af_unix sockets, and the effect is
> quite significant when you hit a compaction, or with
> this patch avoid get in to compaction, but it
> can also be used for reducing the pressure on memory
> for tcp. And the patches you suggested have been
> applied (with the addition "af_unix: fix bug on large send()")
> I see that there is a lot of other compaction fixes
> recently but the problem are still there. And of course
> to make any difference you need to change your
> userland application too. But in our Qualcomm/Google
> bastard to kernel. It makes a huge difference on the
> behaviour of send(). But I also does not see this as
> perfect solution. A wake-up function that has
> the buffers reserved would be better.Or a pre allocated
> send buffer would also be better. But I dont expect that
> linux will have a real-time socket implementation in
> near future.

I have no evidence the problem you describe still exists in current
linux kernels.

Please patch your kernels, but do not send networking patches that seem
to work around a mm-layer problem, without notifying mm maintainers.
