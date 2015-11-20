From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Thu, 19 Nov 2015 16:12:25 -0800
Message-ID: <CAHo-Oozuw3szyZU_CqTph76bQfVgtppFgKCdRJ8GfHeG-zuuSQ@mail.gmail.com>
References: <CAKD1Yr2OgJT0GsrTuws0oapobrU+ML3NpBNBXizg6q035PH4MA@mail.gmail.com>
	<20151119.005318.838757439536205791.davem@davemloft.net>
	<CANP3RGcPRzSL06qZB9oewrvN_AUUodnYzXQO=itoK40z64x8Yw@mail.gmail.com>
	<20151119.104811.1447518072450380661.davem@davemloft.net>
	<1447949964.22599.220.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Lorenzo Colitti <lorenzo@google.com>,
	hannes@stressinduktion.org, stephen@networkplumber.org,
	Linux NetDev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, ek@google.com,
	dtor@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:34120 "EHLO
	mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759389AbbKTAM1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 19:12:27 -0500
Received: by lffu14 with SMTP id u14so59087185lff.1
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 16:12:26 -0800 (PST)
In-Reply-To: <1447949964.22599.220.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Having comments like "look, just implement application keepalives" is
> not going to work [1][2]. This is terrible, and show lack of
> understanding of the problem. We are not dealing with DC communications
> here. (I wish !)

There's a 3rd reason: keepalives (tcp or application) are actually
undesirable because they burn through your battery.

It's far better to do keepalives on one dedicated connection and kill
all the other non keepalive connections
if you determine via that one that the network is bad (or if you have
some other signals about network badness).
