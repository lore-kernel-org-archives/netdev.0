From: Andreas Schultz <aschultz@warp10.net>
Subject: Re: [tproxy,regression] tproxy broken in 2.6.32
Date: Thu, 26 Nov 2009 18:19:24 +0100
Message-ID: <db81a9a20911260919w1ffded25ref5ae24ee73f8eda@mail.gmail.com>
References: <db81a9a20911230443h443b3c2l8fab5aef7b09cfa@mail.gmail.com>
	 <1259137434.9191.3.camel@nienna.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: tproxy@lists.balabit.hu, netdev@vger.kernel.org,
	jamal <hadi@cyberus.ca>
To: KOVACS Krisztian <hidden@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:20804 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760448AbZKZRTT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2009 12:19:19 -0500
Received: by ey-out-2122.google.com with SMTP id 4so251532eyf.19
        for <netdev@vger.kernel.org>; Thu, 26 Nov 2009 09:19:24 -0800 (PST)
In-Reply-To: <1259137434.9191.3.camel@nienna.balabit>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

git bisect shows that TPROXY has been broken by commit
f7c6fd2465d8e6f4f89c5d1262da10b4a6d499d0, [PATCH] net: Fix RPF to work
with policy routing

I had a look at the patch, and it seems logical that this would break TPROXY.

Andreas

On Wed, Nov 25, 2009 at 9:23 AM, KOVACS Krisztian <hidden@balabit.hu> wrote:
> Hi,
>
> On Mon, 2009-11-23 at 13:43 +0100, Andreas Schultz wrote:
>> I was trying to replace a setup based on a 2.6.27.14 kernel with a
>> 2.6.32-rc8 kernel and found that TPROXY is no longer working.
>>
>> The 2.6.27.14 kernel had the last stable tproxy patch plus some
>> additional fixes (TIME_WAIT, inet_sk_flowi_flags).
>> Since 2.6.32 is supposed to have working tproxy support, i dropped all patches.
>>
>> Now, connections to the local tproxy port no longer arrive at that port.
>> From the kernel log:
>>
>> Nov 23 12:32:31 scg01-wiwob user.debug kernel: tproxy socket lookup:
>> proto 6 ac19c4df:49175 -> c0a80208:80, lookup type: 2, sock (null)
>> Nov 23 12:32:31 scg01-wiwob user.debug kernel: tproxy socket lookup:
>> proto 6 ac19c4df:49175 -> c0a80208:3128, lookup type: 1, sock debae040
>> Nov 23 12:32:31 scg01-wiwob user.debug kernel: redirecting: proto 6
>> c0a80208:80 -> 00000000:3128, mark: 880400a0
>>
>>
>> The redirecting message is the last indication of the packet. tcpdump
>> shows that no answer for the initial packet goes out and the listening
>> socket it not notified either.
>
> I'll have a look at this. In the meantime, could you please post your
> kernel config, along with a summary of the iptables & ip rules you're
> using?
>
> Cheers,
> Krisztian
>
>
