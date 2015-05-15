From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH -next 2/3] net: sched: remove AT INGRESS/EGRESS
Date: Fri, 15 May 2015 18:43:07 -0400
Message-ID: <5556767B.2010700@mojatatu.com>
References: <1431679850-31896-1-git-send-email-fw@strlen.de> <1431679850-31896-3-git-send-email-fw@strlen.de> <20150515162319.GA8234@Alexeis-MBP.westell.com> <20150515172115.GK6179@breakpoint.cc> <20150515200944.GA8527@Alexeis-MacBook-Pro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:38242 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934194AbbEOWnP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 18:43:15 -0400
Received: by igcau1 with SMTP id au1so9092150igc.1
        for <netdev@vger.kernel.org>; Fri, 15 May 2015 15:43:15 -0700 (PDT)
In-Reply-To: <20150515200944.GA8527@Alexeis-MacBook-Pro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/15/15 16:09, Alexei Starovoitov wrote:
> On Fri, May 15, 2015 at 07:21:15PM +0200, Florian Westphal wrote:
>> So, from ifb point of view it makes no difference, G_TC_FROM+AT_STACK
>> causes skb to be dropped and IFB doesn't care about G_TC_AT() at all.
>
> yes. your change is technically correct. It's not causing ifb regression,
> but it removes information in a way that will be very hard to add it later.
>
>> AT_STACK cannot even happen for the G_TC_AT case from looking at the
>> code since dev_queue_xmit forces AT_EGRESS & rx sets AT_INGRESS.
>
> yes, if we only consider ingress and egress hooks.
> I want to use this stack/ingress/egress indication with socket filters.
> If we make stack==egress, I would need to refactor this code all over again.
> It's not broken today. You're doing this aliasing only two squeeze a bit.
> That's why I'm saying keep the stack/ingress/egress flag as-is. It's useful.
>

My point as well. Using ifb or mirred as examples is fine
but they are not the only potential consumers/producers. Using examples
as such is out of place when it is an architectural issue.
So i would rather this be left alone.

cheers,
jamal
