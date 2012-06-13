From: Michal Sojka <sojkam1@fel.cvut.cz>
Subject: Re: [RFC] net/sched/em_canid: Ematch rule to match CAN frames according to their CAN IDs
Date: Wed, 13 Jun 2012 11:52:10 +0200
Message-ID: <878vfr7d4l.fsf@steelpick.2x.cz>
References: <1339508913-7784-1-git-send-email-lisovy@gmail.com> <1339509809.22704.149.camel@edumazet-glaptop> <1339511593.22704.157.camel@edumazet-glaptop> <1339512622.8536.3.camel@lolumad> <4FD76349.6040407@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	lartc@vger.kernel.org, pisa@cmp.felk.cvut.cz
To: Oliver Hartkopp <socketcan@hartkopp.net>,
	Rostislav Lisovy <lisovy@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from max.feld.cvut.cz ([147.32.192.36]:38646 "EHLO max.feld.cvut.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752165Ab2FMJ6m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2012 05:58:42 -0400
In-Reply-To: <4FD76349.6040407@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Oliver,

Oliver Hartkopp <socketcan@hartkopp.net> writes:
> Hello Rostislav, hello Eric,
>
> On 12.06.2012 16:50, Rostislav Lisovy wrote:
>
>> On Tue, 2012-06-12 at 16:33 +0200, Eric Dumazet wrote: 
>>> On Tue, 2012-06-12 at 16:03 +0200, Eric Dumazet wrote:
>>>> On Tue, 2012-06-12 at 15:48 +0200, Rostislav Lisovy wrote:
>>>>> em_canid is an ematch capable of classifying CAN frames according to
>>>>> their CAN IDs.
>>>>>
>>>>> This RFC/Patch contains a reworked classifier initially posted in
>>>>> http://www.spinics.net/lists/netdev/msg200114.html
>>>>> The functionality is the same however there is almost 50% reduction
>>>>> in the source code length.
>>>>>
>>>>> There is a slight difference between this ematch and other available
>>>>> ematches. Other ematches implement only a simple match operation and
>>>>> are meant to be combined with logic conjunctions (e.g. AND, OR).
>>>>> Our ematch makes it possible to use up to 32 rules in single
>>>>> 'configuration statement' (with OR semantics). This allows us to take
>>>>> the advantage of the bit field data-structure in the implementation of
>>>>> the match function.
>>>>>
>>>>> Example: canid(sff 0x123 eff 0x124 sff 0x230:0x7f0)
>>>>> This ematch would match CAN SFF frames with the following IDs:
>>>>> 0x123, 0x230--0x23f or EFF frame with ID 0x124.
>
> i tried to figure out the difference between the implementation as classifier
> (link above) and this implementation as an ematch.
>
> Do we have any disadvantages using the ematch? 

The performance of ematch might be slightly lower than of standalone
classifier. Rosta will compare the performance soon. 

> E.g. is it still possible to add additional ematches like checking for
> patterns inside can_frame.data[] (which is located in skb->data) with
> ematch_u32 or e.g. ematch_text ??

AFAIK, this should be possible and it will be a big advantage over
implementation as a standalone classifier.

Regards,
-Michal
