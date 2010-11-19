From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Generalizing mmap'ed sockets
Date: Fri, 19 Nov 2010 13:58:21 -0800
Message-ID: <4CE6F2FD.8080301@hp.com>
References: <AANLkTi=WF2hAGAufv_Anc=b=Fm2WOpOMOv1UrDRvaTHp@mail.gmail.com>	<4CE6ED09.70602@hp.com> <20101119.135213.15239226.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:36544 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932512Ab0KSV6Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 16:58:24 -0500
In-Reply-To: <20101119.135213.15239226.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Fri, 19 Nov 2010 13:32:57 -0800
> 
>>I suppose then one would be able to track the consumer pointer (on tx)
>>to "know" that certain data had been ACKed by the remote?  For TCP
>>anyway - and assuming there wouldn't be a case where TCP might copy
>>the data out of the ring and assert "completion."
> 
> Yes, that's implicit in his design, the kernel manages the consumer
> pointer in the ring and this is how userspace can see when ring entries
> are reusable.

But does one really want to lock-in that the update to the consumer pointer 
means the data has been ACKed by the remote (or I suppose that DMA have 
completed if it were UDP)?  We can think of no case where the stack will want to 
copy out of the ring and assert completion to the user before it got ACKed by 
the remote?  Say when the stack wants to autotune the send socket buffer size to 
something larger than the tx ring?

rick
