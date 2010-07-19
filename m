From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Raise initial congestion window size / speedup slow start?
Date: Mon, 19 Jul 2010 10:08:24 -0700
Message-ID: <4C448688.1070507@hp.com>
References: <4C3D94E3.9080103@wildgooses.com> <4C3DD5EB.9070908@tmr.com>	<20100714.111553.104052157.davem@davemloft.net>	<AANLkTil3MVGwJUG12dikut9X1s9Ozc_3GwMjx_gErvxI@mail.gmail.com>	<1279299709.2156.5814.camel@tng> <AANLkTil_c-TH6k2BDW2r5c0HYXFxiu85aMda1bT0nJt3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McManus <mcmanus@ducksong.com>,
	David Miller <davem@davemloft.net>, davidsen@tmr.com,
	lists@wildgooses.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "H.K. Jerry Chu" <hkjerry.chu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:20201 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753705Ab0GSRI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 13:08:27 -0400
In-Reply-To: <AANLkTil_c-TH6k2BDW2r5c0HYXFxiu85aMda1bT0nJt3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

H.K. Jerry Chu wrote:
> On Fri, Jul 16, 2010 at 10:01 AM, Patrick McManus <mcmanus@ducksong.com> wrote:
>>can you tell us more about the impl concerns of initcwnd stored on the
>>route?
> 
> 
> We have found two issues when altering initcwnd through the ip route cmd:
> 1. initcwnd is actually capped by sndbuf (i.e., tcp_wmem[1], which is
> defaulted to a small value of 16KB). This problem has been made obscured
> by the TSO code, which fudges the flow control limit (and could be a bug by
> itself).

I'll ask my Emily Litella question of the day and inquire as to why that would 
be unique to altering initcwnd via the route?

The slightly less Emily Litella-esque question is why an appliction with a 
desire to know it could send more than 16K at one time wouldn't have either 
asked via its install docs to have the minimum tweaked (certainly if one is 
already tweaking routes...), or "gone all the way" and made an explicit 
setsockopt(SO_SNDBUF) call?  We are in a realm of applications for which there 
was a proposal to allow them to pick their own initcwnd right?  Having them pick 
an SO_SNDBUF size would seem to be no more to ask.

rick jones

sendbuf_init = max(tcp_mem,initcwnd)?
