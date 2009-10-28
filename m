From: Ben Greear <greearb@candelatech.com>
Subject: Re: iproute uses too small of a receive buffer
Date: Wed, 28 Oct 2009 12:19:03 -0700
Message-ID: <4AE89927.9090405@candelatech.com>
References: <4AE77F64.3090302@candelatech.com> <20091027162434.6dc31b2d@nehalam> <4AE7F859.7020105@gmail.com> <4AE895E8.60308@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	NetDev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:55136 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752269AbZJ1TTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 15:19:10 -0400
In-Reply-To: <4AE895E8.60308@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/28/2009 12:05 PM, Patrick McHardy wrote:
> Eric Dumazet wrote:
>> Stephen Hemminger a =E9crit :
>>> Just having larger buffer isn't guarantee of success. Allocating
>>> a huge buffer is not going to work on embedded.
>>>
>>
>> Please note we do not allocate a big buffer, only allow more small s=
kbs
>> to be queued on socket receive queue.
>>
>> If memory is not available, skb allocation will eventually fail
>> and be reported as well, embedded or not.
>>
>> I vote for allowing 1024*1024 bytes instead of 32768,
>> and eventually user should be warned that it is capped by
>> /proc/sys/net/core/rmem_max
>
> How about this? It will double the receive queue limit on ENOBUFS
> up to 1024 * 1024b, then bail out with the normal error message on
> further ENOBUFS.
>
> Signed-off-by: Patrick McHardy<kaber@trash.net>

=46irst:  This still pretty much guarantees that messages will be lost =
when
the program starts (when messages are coming in too large of chunks for=
 small buffers)
If you are debugging something tricky, having lost messages will be
very annoying!

Second:  Why bail on ENOBUFS at all?  I don't see how it helps the user
since they will probably just have to start it again, and will miss mor=
e
messages than keeping going would have.

And, even 1MB may not be enough for some scenarios.  So, probably best =
to
let users over-ride the initial setting on cmd-line.  If not, then use
a large value to start with.

Thanks,
Ben



--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

