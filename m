From: Octavian Purdila <octavian.purdila@intel.com>
Subject: Re: [PATCH] tcp: add gfp parameter to tcp_fragment
Date: Fri, 6 Jun 2014 19:20:28 +0300
Message-ID: <CAE1zotLeLTJjjXiVYZjv5r9yR6Y9KiiLDRJXhQBdBFJ6zdw7AQ@mail.gmail.com>
References: <1402065157-29595-1-git-send-email-octavian.purdila@intel.com>
	<1402069955.3645.300.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Christoph Paasch <christoph.paasch@uclouvain.be>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:38342 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751660AbaFFQUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 12:20:30 -0400
Received: by mail-wi0-f180.google.com with SMTP id ho1so1298761wib.13
        for <netdev@vger.kernel.org>; Fri, 06 Jun 2014 09:20:28 -0700 (PDT)
In-Reply-To: <1402069955.3645.300.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 6, 2014 at 6:52 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2014-06-06 at 17:32 +0300, Octavian Purdila wrote:
>> tcp_fragment can be called from process context (from tso_fragment).
>> Add a new gfp parameter to allow it to preserve atomic memory if
>> possible.
>>
>> Signed-off-by: Octavian Purdila <octavian.purdila@intel.com>
>> Reviewed-by: Christoph Paasch <christoph.paasch@uclouvain.be>
>> ---
>
> Seems fine to me.
>
> I am curious to know why you need this ?
>
> It seems real issue here might be different.
>
> Is it because of some performance issue ?
>

No, we noticed this while doing cleaning up the MPTCP code (where
tcp_fragment calls from process context are more frequent) , and we
thought it might be useful upstream as well.
