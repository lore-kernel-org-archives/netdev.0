From: Martin Devera <martin.devera@cdi.cz>
Subject: Re: [PATCH] sch_htb.c consume the classes's tokens bellow the 	HTB_CAN_SEND
 level
Date: Wed, 04 Nov 2009 13:15:34 +0100
Message-ID: <4AF17066.1050504@cdi.cz>
References: <4AEF9862.8040404@gmail.com>	 <412e6f7f0911030518w7a5f02a4ue8a4b6539496dd8f@mail.gmail.com>	 <20091103230035.GA2352@ami.dom.local>	 <412e6f7f0911031753m4af1467fn1b0326bdf17fe48b@mail.gmail.com>	 <20091104082808.GA6224@ff.dom.local>	 <412e6f7f0911040116q6b25b705k83e5a45464698af1@mail.gmail.com>	 <20091104104245.GB6224@ff.dom.local> <4AF15E73.30806@cdi.cz>	 <412e6f7f0911040330uc5ebbcekfef57854fce501f@mail.gmail.com>	 <4AF16C49.409@cdi.cz> <412e6f7f0911040408w5adcdde8yc1add4a561e90e40@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Jamal Hadi Salim <hadi@cyberus.ca>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.cdi.cz ([80.95.109.117]:44283 "EHLO luxik.cdi.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755669AbZKDMPe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Nov 2009 07:15:34 -0500
In-Reply-To: <412e6f7f0911040408w5adcdde8yc1add4a561e90e40@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao wrote:
> On Wed, Nov 4, 2009 at 7:58 PM, Martin Devera <martin.devera@cdi.cz> wrote:
>> Ahh I'm starting to understand. You are concerned mainly with
>>
>> cl->tokens += diff;     /* we moved t_c; update tokens */
>>
>> am I right ?
>>
> 
> If we don't need to charge the tokens, updating it is necessary. I am
> arguing the tokens isn't updated with the ctokens when the
> corresponding class is in HTB_MAY_BORROW mode.
> 

Ok, then the reason is in "logic". When you have parent P and children
A,B each with half of rate and only A is sending, than we want A to use
its own rate and also B's rate. B's rate is available as excess in P.
Here I see correct to charge part to A and part to P, while you want
to charge one P and twice A. Only mbuffer will limit the duplicity.
And it is not good idea because tokens can go very negative and then 
ittroduce A's stall for some time.
I see no principial benefit...
