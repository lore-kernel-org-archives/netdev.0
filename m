From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: Increasing skb->mark size
Date: Tue, 01 Dec 2015 23:09:35 +0100
Message-ID: <565E1A9F.7040906@iogearbox.net>
References: <1448397144.14854.27.camel@mattb-dl>	<CAKD1Yr3URKzAooiNH7i4kHVR0-TQjEAkQEdqjarAm6uxH7u-Mw@mail.gmail.com> <87610ivv6u.fsf@tassilo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matt Bennett <Matt.Bennett@alliedtelesis.co.nz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Luuk Paulussen <Luuk.Paulussen@alliedtelesis.co.nz>,
	davem@davemloft.net
To: Andi Kleen <andi@firstfloor.org>,
	Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46094 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757138AbbLAWJu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 17:09:50 -0500
In-Reply-To: <87610ivv6u.fsf@tassilo.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/01/2015 08:13 PM, Andi Kleen wrote:
> Lorenzo Colitti <lorenzo@google.com> writes:
>> On Wed, Nov 25, 2015 at 5:32 AM, Matt Bennett
>> <Matt.Bennett@alliedtelesis.co.nz> wrote:
>>> I'm emailing this list for feedback on the feasibility of increasing
>>> skb->mark or adding a new field for marking. Perhaps this extension
>>> could be done under a new CONFIG option.
>>
>> 64-bit marks (both skb->mark and sk->sk_mark) would be useful for
>> hosts doing complex policy routing as well. Current Android releases
>> use 20 of the 32 bits. If the mark were 64 bits, we could put the UID
>> in it, and stop using ip rules to implement per-UID routing.
>
> This would be be great. I've recently ran into some issues with
> the overhead of the Android firewall setup.
>
> So basically you need 4 extra bytes in sk_buff. How about:
>
> - shrinking skb->priority to 2 byte

That wouldn't work, see SO_PRIORITY and such (4 bytes) ...

> - skb_iff is either skb->dev->iff or 0. so it could be replaced with a
> single bit flag for the 0 case.

... and that one wouldn't work on ingress.

Hmm, thinking out loud, maybe it makes sense to combine {mark, priority}
into a mark64 field as union, if the use-case allows to ignore/overwrite
priorities set by applications, or to infer them otherwise based on
different policies like net_prio cgroup (see skb_update_prio()).
