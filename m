From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 1/3 v2][NET] gen_estimator: faster gen_kill_estimator
Date: Tue, 22 Jan 2008 08:54:28 -0500
Message-ID: <1201010068.4443.66.camel@localhost>
References: <20080122072152.GA977@ff.dom.local>
	 <1201002127.4443.32.camel@localhost>  <20080122122927.GE2079@ff.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	slavon@bigtelecom.ru, kaber@trash.net
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.177]:9593 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751761AbYAVNyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 08:54:32 -0500
Received: by py-out-1112.google.com with SMTP id u52so3594108pyb.10
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2008 05:54:31 -0800 (PST)
In-Reply-To: <20080122122927.GE2079@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-22-01 at 13:29 +0100, Jarek Poplawski wrote:
> On Tue, Jan 22, 2008 at 06:42:07AM -0500, jamal wrote:
> ...
> > Jarek,
> > 
> > That looks different from the suggestion from Dave.
> 
> Hmm..., I'm not sure you mean my or your suggestion here, but you
> are right anyway...

Your idea to grab a pointer to the estimator so you can quickly find it
upon destruction is a good one.
The challenge was not to break the ABI to user space.
Dave suggested to use a different struct for the kernel side and
maintain the user one as is[1]. Your patch didnt do this, hence my
statement;->

> Maybe I miss something, but there still could be a lot of this walking

Indeed, that is possible in the case of many estimators configured with
the same interval - because they will all fall in the same table bucket
and the idx is not that useful to begin with.

I was wrong given the nature of interval - the majority of the users
will have an estimator interval of say 1 sec which will put everything
in one bucket still. 
We could introduce a proper index that will allow proper distribution
and have that stored by the class. I am not sure i made sense.
But you are coding - and your idea sounds better.

cheers,
jamal


[1] This is _not uncommon_ (note the usage of double negation here for
emphasis;->) technique actually; ones that go further for example can be
found all over the net/sched code (struct tcf_police vs tc_police) etc.



