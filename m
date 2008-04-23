From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Socket buffer sizes with autotuning
Date: Wed, 23 Apr 2008 09:32:50 -0700
Message-ID: <480F64B2.7060608@hp.com>
References: <480E8523.4030007@hp.com>	<1e41a3230804221917m4af32ed9ice8225c943d3ffa2@mail.gmail.com> <20080422.205945.229828014.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: johnwheffner@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:24503 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119AbYDWQcx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 12:32:53 -0400
In-Reply-To: <20080422.205945.229828014.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: "John Heffner" <johnwheffner@gmail.com>
> Date: Tue, 22 Apr 2008 19:17:39 -0700
> 
> 
>>On Tue, Apr 22, 2008 at 5:38 PM, Rick Jones <rick.jones2@hp.com> wrote:
>>
>>> oslowest:~# netstat -an | grep ESTAB
>>> ...
>>> tcp    0 2760560 10.208.0.1:40500    10.208.0.45:42049   ESTABLISHED
>>> ...
>>>
>>> Is this expected behaviour?
>>
>>What is your interface txqueuelen and mtu? 

1000, MTU 1500 and TSO is enabled.

>> If you have a very large interface queue, TCP will happily fill it
>> up unless you are using a delay-based congestion controller.

At the same time, the sender will not try to send any more than the 
receiver is willing to advertise as window.

> Yes, that's the fundamental problem with loss based congestion
> control.  If there are any queues in the path, TCP will fill them up.
> 
> Vegas and other similar techniques are able to avoid this, but come
> with the fundamental flaw that it's easy to get them into situations
> where they do not respond to increases in pipe space adequately, and
> thus underperform compared to loss based algorithms.

I can see that for the sending side being willing to send into the 
receiver's ever increasing window, but is autotuning supposed to keep 
growing and growing the receive window the way it seems to be?

rick jones
