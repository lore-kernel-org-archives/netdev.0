From: Martin Devera <martin.devera@cdi.cz>
Subject: Re: [PATCH] sch_htb: ix the deficit overflows
Date: Wed, 02 Dec 2009 12:07:44 +0100
Message-ID: <4B164A80.2000709@cdi.cz>
References: <20091128000401.GA3713@ami.dom.local> <412e6f7f0911292026w704a70b8yc3af2c2473e05d34@mail.gmail.com> <20091130111020.GA7114@ff.dom.local> <20091202.012017.39623676.davem@davemloft.net> <20091202103204.GA7724@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, xiaosuo@gmail.com,
	hadi@cyberus.ca, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.cdi.cz ([80.95.109.117]:50384 "EHLO luxik.cdi.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751312AbZLBLHu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2009 06:07:50 -0500
In-Reply-To: <20091202103204.GA7724@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
>>
>> Because we toss large SKBs all over the strack quite freely,
>> protections like those suggested by Changli make perfect sense.
>>
>> We really don't have an MTU for packets within our stack any more.
>> The code, by default, need to be able to handle anything.
> 
> Alas, an MTU is still a crucial parameter for some schedulers. Anyway,
> I hope Changli wasn't mislead to treat my private opinions in this or
> any other thread as decisive. Otherwise, I'm sorry.

It seems that the new code is not slower when quantums are larger
than MTU's. Only when it is not the case, the new code introduces
loop which will iteratively increase deficit[x] until some packet
fits.
This can slow dequeue down. I'm not sure how much - but imagine
working setup with small quantums which works just now (only
sharing ratios are wrong).
After installing new kernel with the change the load could go
up and router could start  dropping packets.

While I don't believe the load will change so much, Changli
should measure this one IMHO.

