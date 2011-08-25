From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH] tcp: bound RTO to minimum
Date: Wed, 24 Aug 2011 18:50:29 -0700
Message-ID: <CAK6E8=dXf=wsZOB+ZUNuUpLyV2vrcgf7pvwYPz1YTmF81WuGDA@mail.gmail.com>
References: <1314226834.6797.5.camel@edumazet-laptop> <1314229310-8074-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:38896 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751791Ab1HYBuw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 21:50:52 -0400
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p7P1oo7J001914
	for <netdev@vger.kernel.org>; Wed, 24 Aug 2011 18:50:51 -0700
Received: from gyd5 (gyd5.prod.google.com [10.243.49.197])
	by wpaz1.hot.corp.google.com with ESMTP id p7P1oSX7011740
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 24 Aug 2011 18:50:49 -0700
Received: by gyd5 with SMTP id 5so1375624gyd.15
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2011 18:50:49 -0700 (PDT)
In-Reply-To: <1314229310-8074-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 24, 2011 at 4:41 PM, Hagen Paul Pfeifer <hagen@jauu.net> wrote:
> Check if calculated RTO is less then TCP_RTO_MIN. If this is true we
> adjust the value to TCP_RTO_MIN.
>
but tp->rttvar is already lower-bounded via tcp_rto_min()?

static inline void tcp_set_rto(struct sock *sk)
{
...

  /* NOTE: clamping at TCP_RTO_MIN is not required, current algo
   * guarantees that rto is higher.
   */
  tcp_bound_rto(sk);
}
