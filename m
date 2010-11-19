From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Generalizing mmap'ed sockets
Date: Fri, 19 Nov 2010 13:32:57 -0800
Message-ID: <4CE6ED09.70602@hp.com>
References: <AANLkTi=WF2hAGAufv_Anc=b=Fm2WOpOMOv1UrDRvaTHp@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:7543 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752823Ab0KSVdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 16:33:09 -0500
In-Reply-To: <AANLkTi=WF2hAGAufv_Anc=b=Fm2WOpOMOv1UrDRvaTHp@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I suppose then one would be able to track the consumer pointer (on tx) to "know" 
that certain data had been ACKed by the remote?  For TCP anyway - and assuming 
there wouldn't be a case where TCP might copy the data out of the ring and 
assert "completion."

How would the mmap'ing interact with autotuning?  Particularly in the "future 
case" of HW support for true zero copy on receive.

Today I can be assured that data I receieve is on a "nice" boundary in my memory 
by virtue of the buffer pointer I pass to the recv() call, but with the "rings" 
(they are simply some chunk of virtually continguous data yes?) it will just be 
bumped up against the end of the last one - I'm wondering if that might not be a 
problem, especially for UDP datagrams, but even for TCP data?  It is one thing 
to have people pad structures in the memory of a system, but telling them to 
pad-out the messages they send across the network to maintain alignment is 
rather different.

How do you differentiate between a "there is data to send" and "I want to send a 
zero-legnth datagram for a UDP socket?  I think you will have to do/overload 
something other than a send() call for the trigger.

rick jones
