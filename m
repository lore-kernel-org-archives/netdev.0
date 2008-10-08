From: Martin Devera <devik@cdi.cz>
Subject: Re: Possible regression in HTB
Date: Wed, 08 Oct 2008 12:47:57 +0200
Message-ID: <48EC8FDD.5030507@cdi.cz>
References: <48EB5A92.6010704@trash.net> <20081007220022.GA2664@ami.dom.local> <20081008002153.GL12021@verge.net.au> <48EBFF5E.1090902@trash.net> <48EC0190.7040804@trash.net> <48EC6286.1030202@cdi.cz> <20081008085325.GF4174@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.wifcom.cz ([89.185.251.8]:51623 "EHLO wifcom.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754725AbYJHKrc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 06:47:32 -0400
In-Reply-To: <20081008085325.GF4174@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> The algorithm samples queue states at deterministic but unregular
>> intervals to see whose classes wants service and whose can lend.
>>
>> If you hold a packet outside, relevant class thinks that it is
>> not backlogged - and if sampled at this time then the algorithm
>> decides to lend classe's time.
> 
> Right, but on the other hand I can't see any correction of these
> times/tokens, so it seems this can't give us "right" results
> anyway? E.g. with 100% requeuing (each packet requeued once) HTB
> should think it "gave" the rate 2x higher than seen on the other
> side - or I miss something?

Yes, it is another problem - double acounting packet when requeued...
Well, you are right, the number are not too supportive to this
explanation...
It seems that the first class didn't get its basic "rate", which
is should be guaranteed.

Simon, can you try to these things (separately):
a/ increase quantum to the first class (say 10x)
b/ set ceil=rate on all three classes

The idea is to a/ make sure there is no requeue-related change
to the drr pointer which could boost reqeued class,
b/ to see whether priorized class has problems to send or
other classes are sending even when they should not.

>> Thus, from qdisc point, it is not good to keep a packet for
>> more time out of the qdisc.
> 
> Sure, the question is how much it's useful against associated
> code complications and additional cpu usage.

honestly, I'm not familiar with the new code. Can you tell me
in short what is gso_skb and where the skb goes now if not requeued ?

thanks, Martin
