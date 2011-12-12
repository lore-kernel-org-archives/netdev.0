From: Vladislav Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH RESEND] sctp: fix incorrect overflow check on autoclose
Date: Mon, 12 Dec 2011 17:18:46 -0500
Message-ID: <4EE67DC6.3000500@hp.com>
References: <1323393883-3759-1-git-send-email-xi.wang@gmail.com> <4EE2478B.5010409@hp.com> <8EEC521A-CA38-4CE9-BCFD-BA6FC9A85D18@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Andrei Pelinescu-Onciul <andrei@iptel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Xi Wang <xi.wang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:23905 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754287Ab1LLWSy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 17:18:54 -0500
In-Reply-To: <8EEC521A-CA38-4CE9-BCFD-BA6FC9A85D18@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/09/2011 01:04 PM, Xi Wang wrote:
> On Dec 9, 2011, at 12:38 PM, Vladislav Yasevich wrote:
>> I think this should be u32 since that's what sp->autoclose is.
> 
> Do you mean something like this?
> 
> 	min_t(u32, sp->autoclose, MAX_SCHEDULE_TIMEOUT / HZ)
> 
> On 64-bit platform this would limit autoclose for no good
> reason to
> 
> 	(u32)(MAX_SCHEDULE_TIMEOUT / HZ),
> 
> which is basically 0x978d4fdf (assuming HZ is 250).  I guess the
> intention was to allow autoclose to be any u32 on 64-bit platform.
> 

Hm..  this is a bit strange.  This makes it so that on 32 bit platforms
we have one upper bound for autoclose and on 64 we have another even though
the type is platform dependent.  This could be considered a regression by
applications.

In addition this would result in confusion to user since the values
between setsockopt() and getsockopt() for autoclose would be different.

Looking at the latest spec, it actually looks like we are completely
mis-interpreting autoclose.  It's supposed to be in seconds.

For now, I'd suggest to make this consistent between 32 and 64 bits.
Having inconsistent values seems strange.

As a next set the api needs to be fixed to accept seconds as
argument.

-vlad
