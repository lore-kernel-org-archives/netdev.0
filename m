From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next v5 10/11] tbf: take into account gso skbs
Date: Sun, 17 Feb 2013 09:54:23 -0800
Message-ID: <1361123663.19353.94.camel@edumazet-glaptop>
References: <1360663929-1023-1-git-send-email-jiri@resnulli.us>
	 <1360663929-1023-11-git-send-email-jiri@resnulli.us>
	 <1360687182.6884.5.camel@edumazet-glaptop>
	 <20130217161803.GB1931@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	jhs@mojatatu.com, kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:35398 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751490Ab3BQRyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Feb 2013 12:54:25 -0500
Received: by mail-pb0-f52.google.com with SMTP id ma3so1301671pbc.39
        for <netdev@vger.kernel.org>; Sun, 17 Feb 2013 09:54:25 -0800 (PST)
In-Reply-To: <20130217161803.GB1931@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-02-17 at 17:18 +0100, Jiri Pirko wrote:

> I'm going through this issue back and front and on the second thought,
> I think this patch might not be so wrong after all.
> 
> "Accumulating" time in ptoks would effectively cause the skb to be sent
> only in case time for whole skb is available (accumulated).
> 
> The re-segmenting will only cause the skb fragments sent in each time frame.
> 
> I can't see how the bigger bursts you are reffering to can happen.
> 
> Or am I missing something?

Token Bucket Filter doesnt allow to accumulate tokens above a given
threshold. Thats the whole point of the algo.

After a one hour idle time, you don't want to allow your device sending
a burst exceeding the constraint.

This is all about avoiding packet drops in a device with a very small
queue.

Your patch was pretty close to solve the problem.
