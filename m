From: Peter Fassberg <pf@leissner.se>
Subject: Re: Default network namespace name
Date: Wed, 21 May 2014 19:21:48 +0200 (SST)
Message-ID: <alpine.BSF.2.00.1405211908090.47766@nic-i.leissner.se>
References: <alpine.BSF.2.00.1405210826570.47766@nic-i.leissner.se> <CAKoUAr=68yxKqmPx8u9bfE8a-_bnonGZw-FcD=p-bw6=OARZ8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Netdev <netdev@vger.kernel.org>
To: Rami Rosen <roszenrami@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgate.leissner.se ([212.3.1.210]:14267 "EHLO
	mailgate.leissner.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751944AbaEURVx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 13:21:53 -0400
In-Reply-To: <CAKoUAr=68yxKqmPx8u9bfE8a-_bnonGZw-FcD=p-bw6=OARZ8A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Rami,

This was very interesting.

How does "ip link set" distinguish between PID 1 and a namespace named "1"?


Nicolas proposed a very useful solution, which was exactly what I was looking for:
touch /var/run/netns/default
mount --bind /proc/1/ns/net /var/run/netns/default

It work like a charm!

Thank you all!



Regards,

Peter




On Wed, 21 May 2014, Rami Rosen wrote:

> Hi,
>
> The default, initial network namespace does not have a name. In fact,
> according to the kernel implementation, all namespaces (and in
> particular, the network namespace) do not have names. The names of the
> network namespaces are created and deleted by the userspace "ip netns"
> command.
>
> You can move network interfaces to the initial namespace using pid 1,
> for example:
>
> ip netns add myns2
> ip link set p4p1 netns myns2
>
> #start bash in myns2
> ip nents exec myns2 bash
>
> #move p4p1 from myns2 to the default network namespace
>
> ip link set p4p1 netns 1
>
> Regards,
> Rami Rosen
>
> http://ramirose.wix.com/ramirosen
>
>
> On Wed, May 21, 2014 at 9:36 AM, Peter Fassberg <pf@leissner.se> wrote:
>>
>> Hi!
>>
>> Is there a name of the default network namespace?
>>
>> I would like to execute a command in the default network namespace while
>> running a shell in a non-default namespace.
>>
>> Like this: ip netns exec "" ip link
>> Or this:   ip netns exec . ip link
>>
>> That command end up with a mis-spelled error message: :)
>> seting the network namespace "" failed: Invalid argument
>>
>>
>>
>> Regards,
>>
>> Peter
>>
