From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v5 10/11] tbf: take into account gso skbs
Date: Tue, 19 Feb 2013 17:46:26 +0100
Message-ID: <20130219164626.GC1506@minipsycho.orion>
References: <1360663929-1023-1-git-send-email-jiri@resnulli.us>
 <1360663929-1023-11-git-send-email-jiri@resnulli.us>
 <1360687182.6884.5.camel@edumazet-glaptop>
 <20130217161803.GB1931@minipsycho.orion>
 <1361123663.19353.94.camel@edumazet-glaptop>
 <20130218095837.GA1566@minipsycho.orion>
 <1361290502.19353.136.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	jhs@mojatatu.com, kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:39896 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758462Ab3BSQqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 11:46:31 -0500
Received: by mail-ee0-f43.google.com with SMTP id c50so3478865eek.30
        for <netdev@vger.kernel.org>; Tue, 19 Feb 2013 08:46:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1361290502.19353.136.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Feb 19, 2013 at 05:15:02PM CET, eric.dumazet@gmail.com wrote:
>On Mon, 2013-02-18 at 10:58 +0100, Jiri Pirko wrote:
>> Sun, Feb 17, 2013 at 06:54:23PM CET, eric.dumazet@gmail.com wrote:
>> >On Sun, 2013-02-17 at 17:18 +0100, Jiri Pirko wrote:
>> >
>> >> I'm going through this issue back and front and on the second thought,
>> >> I think this patch might not be so wrong after all.
>> >> 
>> >> "Accumulating" time in ptoks would effectively cause the skb to be sent
>> >> only in case time for whole skb is available (accumulated).
>> >> 
>> >> The re-segmenting will only cause the skb fragments sent in each time frame.
>> >> 
>> >> I can't see how the bigger bursts you are reffering to can happen.
>> >> 
>> >> Or am I missing something?
>> >
>> >Token Bucket Filter doesnt allow to accumulate tokens above a given
>> >threshold. Thats the whole point of the algo.
>> >
>> >After a one hour idle time, you don't want to allow your device sending
>> >a burst exceeding the constraint.
>> 
>> You are right, therefore I said "not so wrong". Let me illustrate my
>> thoughts. Here is a patch:
>> 
>> Subject: [patch net-next RFC] tbf: take into account gso skbs
>> 
>> Ignore max_size check for gso skbs. This check made bigger packets
>> incorrectly dropped. Remove this limitation for gso skbs.
>> 
>> Also for peaks, accumulate time for big gso skbs.
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>
>I am sorry, we can not do this accumulation.
>
>If we are allowed to send 1k per second, we are not allowed to send 10k
>after 10 seconds of idle.
>
>Either we are able to split the GSO packet, and respect the TBF
>constraints, either we must drop it.


That's a shame. Would be easy this way, also applicable to act_police :/

About the gso_segment, do you see any cons doing that on enqueue path
rather than dequeue?

Thanks.
