From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH/RFC net-next] rocker: remove rocker parameter from
 functions that have rocker_port parameter
Date: Thu, 28 May 2015 08:53:20 -0700
Message-ID: <CAE4R7bC7qt9LhDqvpb-ZvWB6te=nf4DgXrC0T4NT7DX2yrCgrw@mail.gmail.com>
References: <1432783397-12868-1-git-send-email-simon.horman@netronome.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CB417A2@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Simon Horman <simon.horman@netronome.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f172.google.com ([209.85.216.172]:36271 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754271AbbE1PxV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 11:53:21 -0400
Received: by qcxw10 with SMTP id w10so16085977qcx.3
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 08:53:20 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB417A2@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 28, 2015 at 2:18 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Simon Horman
>> Sent: 28 May 2015 04:23
>> The rocker (switch) of a rocker_port may be trivially obtained from
>> the latter it seems cleaner not to pass the former to a function when
>> the latter is being passed anyway.
>
> If the arguments are passed in registers (they almost certainly are)
> or the function is inlined (possible since they are static) and
> the calling code already has both values in registers then
> passing both values saves a memory read inside the called code.
>
> So on 'hot paths' it probably makes sense to pass both values.

Agreed, and Simon's patch is 99% cold path, so I'd rather trade
clarity in the code than saving a nanosec in a driver cold path.

Simon, would you respin, remove rocker_port_rx_proc() changes, remove
RFC, and add my ack?  rocker_port_rx_proc() was the only hot path case
I found.

-scott
