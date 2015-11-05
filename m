From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: AF_PACKET mmap() v4...
Date: Thu, 05 Nov 2015 10:39:15 +0100
Message-ID: <563B23C3.5070406@iogearbox.net>
References: <20151105.000414.1682124328670738318.davem@davemloft.net> <4931220.z2MFa8LzkQ@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35054 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756364AbbKEJjS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 04:39:18 -0500
In-Reply-To: <4931220.z2MFa8LzkQ@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/05/2015 10:07 AM, Arnd Bergmann wrote:
> On Thursday 05 November 2015 00:04:14 David Miller wrote:
>> As part of fixing y2038 problems, Arnd is going to have to make a new
>> version fo the AF_PACKET mmap() tpacker descriptors in order to extend
>> the time values to 64-bit.
>>
>> So I want everyone to think about whether there are any other changes
>> we might want to make given that we have to make a v4 anyways.
>>
>> Particularly, I am rather certain that the buffer management could be
>> improved.  Some have complained that v3 is kinda awkward to use and/or
>> suboptimal is various ways.
>
> I have taken a closer look at the actual timestamp data now, and noticed
> that we use __u32 for both tp_sec and ts_sec in the user visible data.
> This means that once we fix the internal implementation to use 64-bit
> timestamps, we actually won't overflow until 2106 because the 2038 overflow
> is only for signed 32-bit numbers as we have in 'struct timespec'.
>
> So the good news is that we can keep the existing v1 through v3 formats
> beyond 2038, but only as long as all user space that cares about the
> value also interprets it as unsigned.

Right, I was just about to ask that. So we could just make a union in
AF_PACKET's UAPI for a single 64-bit variable (as in ktime_t) to fix that.

Best,
Daniel
