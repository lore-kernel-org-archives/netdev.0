From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] GENETLINK: Global lock refined to family granularity
Date: Mon, 31 Mar 2008 12:33:50 +0200
Message-ID: <20080331103350.GZ20815@postel.suug.ch>
References: <47EB8D8D.8020506@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Richard MUSIL <richard.musil@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:50514 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751045AbYCaKda (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2008 06:33:30 -0400
Content-Disposition: inline
In-Reply-To: <47EB8D8D.8020506@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Richard MUSIL <richard.musil@st.com> 2008-03-27 13:05
> This patch is a revive of the patch I posted half a year ago. In that time
> Thomas Graf (who was acting as maintainer of genetlink module) accepted
> the idea, but suggested to do it using RCU lists. Since I did not have
> and experience with RCU lists, we agreed, he will implement it himself.
> 
> Since that time, he neither did it, nor replied to my recent emails and
> I guess he is no longer active.

Sorry but I didn't receive any recent emails.

> I am asking, whomever maintains genetlink right now, for including this
> patch. (Currently, this is patch to linux-2.6.25-rc7.)
> 
> The idea behind (i.e. why I needed it) is device driver, which uses
> genetlink to talk to userspace and which creates virtual devices and
> registers families for them in the runtime. So these devices can also
> talk to userspace using genetlink.
> 
> Current implementation prevents that, because processing any single
> genetlink message blocks complete genetlink infrastructure (i.e.
> registrations, and deregistrations).

On a first sight your patch seemed very legitimate although the amount
of locks taken for every single message received was very irritating.
Also your patch explicitely allows registration operations but when the
family being currently received on is manipulated, it will simply deadlock.
So this patch is about allowing registration of operations for other
families at the cost of two additional locks for every message received
combined with complex locking logic. All a bit much for something that
can be easly solved using a workqueue.

BTW, your patch does not account for multicast group registration.
