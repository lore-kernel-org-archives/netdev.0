From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH] TCP_USER_TIMEOUT: a new socket option to specify max
 timeout before a TCP connection is aborted
Date: Sun, 29 Aug 2010 23:54:48 -0700
Message-ID: <AANLkTinrPcJwMs+frY7J_QKuNv1MDGRQAgPgwofuFydw@mail.gmail.com>
References: <1282972408-19164-1-git-send-email-hkchu@google.com>
	<20100828.161320.245404727.davem@davemloft.net>
	<AANLkTimW_7a9=yK4po9FshH0i0LT-MZF+fysGRvgT3jG@mail.gmail.com>
	<20100829.211954.232753860.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: eric.dumazet@gmail.com, hannemann@nets.rwth-aachen.de,
	hagen@jauu.net, lars.eggert@nokia.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:4697 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751597Ab0H3Gyv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 02:54:51 -0400
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id o7U6somZ025338
	for <netdev@vger.kernel.org>; Sun, 29 Aug 2010 23:54:50 -0700
Received: from gwb1 (gwb1.prod.google.com [10.200.2.1])
	by kpbe15.cbf.corp.google.com with ESMTP id o7U6smZd011889
	for <netdev@vger.kernel.org>; Sun, 29 Aug 2010 23:54:49 -0700
Received: by gwb1 with SMTP id 1so2237289gwb.34
        for <netdev@vger.kernel.org>; Sun, 29 Aug 2010 23:54:48 -0700 (PDT)
In-Reply-To: <20100829.211954.232753860.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 29, 2010 at 9:19 PM, David Miller <davem@davemloft.net> wrote:
> From: Jerry Chu <hkchu@google.com>
> Date: Sun, 29 Aug 2010 17:23:05 -0700
>
>> Personally I think as an API, it's easier for an application to
>> grasp the concept of a time quantity than # of
>> retransmissions. (E.g., how will an app determine it needs 10
>> retries vs 20 retries?)
>
> Conversely how can the user grasp how many actual attempts will
> be made if backoff is employed?
>
> It's very easy to under-cap the number of actual packet send
> attempts that will be made specifying just a timeout, in the
> presence of backoff.

My previous statement presumes applications care less about exactly
how many times retransmission attempts have been made because
that's more of "implementation detail" for a reliable transport. But I can
see one can argue either way effectively so I'm ok with both. If people
prefer timeout in # of retries then it just needs to be converted to time
units when used in conjunction with the USER TIMEOUT option (and
one can readily use the existing "retransmits_timed_out()" function,
although the latter presents only an approximation).

Jerry

>
