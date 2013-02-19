From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next v5 10/11] tbf: take into account gso skbs
Date: Tue, 19 Feb 2013 08:15:02 -0800
Message-ID: <1361290502.19353.136.camel@edumazet-glaptop>
References: <1360663929-1023-1-git-send-email-jiri@resnulli.us>
	 <1360663929-1023-11-git-send-email-jiri@resnulli.us>
	 <1360687182.6884.5.camel@edumazet-glaptop>
	 <20130217161803.GB1931@minipsycho.orion>
	 <1361123663.19353.94.camel@edumazet-glaptop>
	 <20130218095837.GA1566@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	jhs@mojatatu.com, kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f53.google.com ([209.85.210.53]:61280 "EHLO
	mail-da0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754764Ab3BSQPO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 11:15:14 -0500
Received: by mail-da0-f53.google.com with SMTP id w3so3026965dad.40
        for <netdev@vger.kernel.org>; Tue, 19 Feb 2013 08:15:13 -0800 (PST)
In-Reply-To: <20130218095837.GA1566@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-02-18 at 10:58 +0100, Jiri Pirko wrote:
> Sun, Feb 17, 2013 at 06:54:23PM CET, eric.dumazet@gmail.com wrote:
> >On Sun, 2013-02-17 at 17:18 +0100, Jiri Pirko wrote:
> >
> >> I'm going through this issue back and front and on the second thought,
> >> I think this patch might not be so wrong after all.
> >> 
> >> "Accumulating" time in ptoks would effectively cause the skb to be sent
> >> only in case time for whole skb is available (accumulated).
> >> 
> >> The re-segmenting will only cause the skb fragments sent in each time frame.
> >> 
> >> I can't see how the bigger bursts you are reffering to can happen.
> >> 
> >> Or am I missing something?
> >
> >Token Bucket Filter doesnt allow to accumulate tokens above a given
> >threshold. Thats the whole point of the algo.
> >
> >After a one hour idle time, you don't want to allow your device sending
> >a burst exceeding the constraint.
> 
> You are right, therefore I said "not so wrong". Let me illustrate my
> thoughts. Here is a patch:
> 
> Subject: [patch net-next RFC] tbf: take into account gso skbs
> 
> Ignore max_size check for gso skbs. This check made bigger packets
> incorrectly dropped. Remove this limitation for gso skbs.
> 
> Also for peaks, accumulate time for big gso skbs.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---

I am sorry, we can not do this accumulation.

If we are allowed to send 1k per second, we are not allowed to send 10k
after 10 seconds of idle.

Either we are able to split the GSO packet, and respect the TBF
constraints, either we must drop it.
