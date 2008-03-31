From: Richard MUSIL <richard.musil@st.com>
Subject: Re: [PATCH] GENETLINK: Global lock refined to family granularity
Date: Mon, 31 Mar 2008 18:14:40 +0200
Message-ID: <47F10DF0.2040102@st.com>
References: <47EB8D8D.8020506@st.com> <20080331103350.GZ20815@postel.suug.ch> <47F0C942.9070603@st.com> <20080331122648.GA20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s200aog11.obsmtp.com ([207.126.144.125]:35464 "EHLO
	s200aog11.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754591AbYCaQO6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 12:14:58 -0400
In-Reply-To: <20080331122648.GA20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31.3.2008 14:26, Thomas Graf wrote:
> * Richard MUSIL <richard.musil@st.com> 2008-03-31 13:21
>> It takes two locks, instead of one. I do not see, how it could be less
>> (in terms of synchronization primitives - but not necessarily mutexes)
>> if I want that level of granularity. Might be more efficient with RCU
>> lists (but I do not know), but complexity remains the same.
> 
> The synchronization mutex in genl_recv() remains and you add an
> additional global mutex genl_fam_lock and a per family lock. That's
> 2 vs 6 lock operations. It is possible to use RCU to manage the

Shame on me, I should know better (what my patch is doing). You are
right, the global lock in genl_recv remains. I guess my further
arguments are now irrelevant.
Concerning the RCU lists, I am also for better solution, the problem is,
I have never used them before, so the probability I will do it right, is
far small - but I may give it try.

<skipped the most since it is no longer relevant>

> I'm not against the idea, I just feel that the gains in your patch in
> its current form do not justify the additional locking and complextity
> costs. Combined with parallel processing and RCU lists it would be a
> no brainer and probably merged instantly.

Ok, I will see, what I can do.

Richard
