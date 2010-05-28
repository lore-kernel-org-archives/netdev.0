From: walter harms <wharms@bfs.de>
Subject: Re: [Patch] fix packet loss and massive ping spikes with PPP 	multi-link
Date: Fri, 28 May 2010 09:28:29 +0200
Message-ID: <4BFF709D.5040005@bfs.de>
References: <2d460de71003260850x7f90d04cy79ac853464108182@mail.gmail.com>	<AANLkTik_QdZN_nFoOVD3-1JTGN5oxRySCdV5_eDqvQve@mail.gmail.com>	<4BFBA3F2.2000301@bfs.de>	<AANLkTilnueP5HIfX03soMCYE93jubL000rpiOCN1xB2-@mail.gmail.com>	<4BFC0942.2030103@bfs.de> <AANLkTikeld4fbr9r1Sq0jhfkWxf0ZlwOsufUIRvb1rFH@mail.gmail.com>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-ppp@vger.kernel.org, erik_list@caneris.com
To: Richard Hartmann <richih.mailinglist@gmail.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <AANLkTikeld4fbr9r1Sq0jhfkWxf0ZlwOsufUIRvb1rFH@mail.gmail.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Richard Hartmann schrieb:
> ==It seems LKML & netdev were dropped from the To list, re-adding==
> 
> Hi Walter,
> 
> 
>>  if (ppp->rrsched % ppp->n_channels == i)
>>
>> since both do not change in that while() loop you can calculate in advance
>> perhaps ppp->rrsched %= ppp->n_channels before the while ?
>> (that would reduce my bad feels about variables that only increments also :)
> 
> rrsched and i do change when appropriate. As they are used as a cheap
> way to get round robin, rrsched is not even initialized. One can argue
> that this should be done, but as it literally does not matter where the
> value starts counting....
> 

yep,
the problem is that you will trigger a warning "variable uninitialised".
And as programmer you are trained to spot such kind of code.
in short you violated "the rule of least surprise", simply set it to 99
and add a comment that the value does not matter because it is actualy a
random seed.
Basicly the same reason for the ppp->rrsched %= ppp->n_channels outside
the loop. 1. people/compiler are happy because they see the variable
is used. 2. no need to recalculate the if in a loop (never trust optimisers).

/*
perhaps rr_chanel is a better name ? round robin channel
that would requiere the changes but explain what it actualy is
*/



> 
>> btw: you are doing  after loop() if(pch->chan == NULL) continue;
>> that means the else in the if below  if (pch->chan) should never be reached.
>> Or is it likely that some channel will be dropped (?) ?
> 
> Channels could be dropped and we need to guard against that.
> 

please add a comment about that. i can garantee you someone will spot it
and remove either the pch->chan == NULL or the else.



just my 2 cents,
wh


> 
>> btw: this is intentional ? looks strange
>>
>>        if(ppp_ml_noexplode) {
>> +       }
>> +       else {
> 
> Leftover from various printks for debugging reasons.
> 
> 
> Thanks for your feedback,
> Richard
> 
