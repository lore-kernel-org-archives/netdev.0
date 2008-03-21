From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH] SCTP: Fix possible memory leak while process INIT chunk
 with AUTH paramters
Date: Fri, 21 Mar 2008 10:16:22 +0800
Message-ID: <47E31A76.6060903@cn.fujitsu.com>
References: <47E20DA8.1080805@cn.fujitsu.com> <47E25794.6050001@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50782 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752171AbYCUCO5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Mar 2008 22:14:57 -0400
In-Reply-To: <47E25794.6050001@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vlad:

Vlad Yasevich wrote:
> Hi Wei
>
> Wei Yongjun wrote:
>> While endpoint received INIT/INIT-ACK chunk with AUTH parameters, 
>> such as RANDOM, HMAC_ALGO, CHUNKS parameter, if those parameters 
>> appear more then once, memory for store those parameters will be 
>> malloc more then once and not free.
>>
>
> All these parameters must be included only once in the packet.

RFC 4890 has the following text:

   The RANDOM parameter MUST be included once in the INIT or INIT-ACK
   chunk, if the sender wants to send or receive authenticated chunks,
   to provide a 32-byte Random Number.  For 32-byte Random Numbers, the
   Padding is empty.


It said *MUST be included once*, not *only once*, is this right?

>
> If these things are included more then once, we should either ABORT or
> completely ignore the packet.  I haven't decided which one makes more
> sense yet.
>
> If someone when to the trouble of violating the protocol, we should not
> establish the association with them.

I think do ABORT with protocol violation is better, do the same thing as 
the other protocol violation case do.

Wei Yongjun

