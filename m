From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH net-next 7/8] net: ip_tunnel: remove 'csum_help' argument
 to iptunnel_handle_offloads
Date: Mon, 11 Jan 2016 19:03:31 +0000
Message-ID: <5693FC83.6060004@solarflare.com>
References: <56901197.8040808@solarflare.com>
 <56901244.8060809@solarflare.com>
 <CAKgT0UdQzW2+n7S3YOhAJVZY-q5bjYaQB0jDn7AD3zp2ZrkGZg@mail.gmail.com>
 <CALx6S34MRoLw_JiHuyDANwoF9+u7k9R-UDb_RGP+L-d9D=f3WQ@mail.gmail.com>
 <CAKgT0UeZwSm4oKoydXWU3iWmjL5m6H=K=hJ2wAkp_GugbZJwjA@mail.gmail.com>
 <5693AD25.4020904@solarflare.com>
 <CAKgT0Ufw9djq-V8YAXjq21gg7rE5=-Dp4o4GmdGk+6Diu4mDNw@mail.gmail.com>
 <5693E6F8.7040806@solarflare.com>
 <CAKgT0UeigRk03syFKNtQu7FR4-de-ShyBeyygEEfjRYZ4SEJ4A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:8860 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934175AbcAKTEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 14:04:15 -0500
In-Reply-To: <CAKgT0UeigRk03syFKNtQu7FR4-de-ShyBeyygEEfjRYZ4SEJ4A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/01/16 18:15, Alexander Duyck wrote:
> On Mon, Jan 11, 2016 at 9:31 AM, Edward Cree <ecree@solarflare.com> wrote:
>> Looks OK to me.  I'd rather tack both of your patches onto the endof the
>>  series, rather than incorporating your patch [1/2] directly into my patch
>>  [1/8]; that way (a) the history allows to understand regular LCO before
>>  adding in the GSO flavour, (b) you're credited for your improved lco_csum.
> Actually if you don't plan to incorporate the function I am fine with
> you just leaving it out for now.  I can focus on the GSO portions of
> all this and rewrite this to just be an update of your patch.  Then
> when you submit your patches and they are accepted I will submit the
> GSO implementations.
Ok, sounds good.
>> As for your patch [2/2], I don't pretend to understand GSO right now but it
>>  looks plausible enough.  Perhaps you could add a document about GSO to go
>>  alongside the checksum-offloads.txt one?
> I don't know if we really need to.  The logic is essentially the same
> as what you already have for the local checksum offload.  The only
> difference is there is the GSO logic floating around in there to also
> compute the outer checksum offload based on the inner that GSO had
> already retained when it did the inner offload via software.
I didn't mean a GSO LCO document, I just meant something to explain GSOas
 a whole.  There doesn't appear to be any documentation in the tree
 defining what e.g. gso_size or gso_segs mean, and yet they are part of
 the driver API for TSO.  Even some comments on struct skb_shared_info
 would be an improvement.
The comment in skbuff.h seems very much to gloss over how GSO and checksum
 offload interact in general.  It also says two checksums can be offloaded
 with UDP tunnels - you might want to update that in your patch.
But hopefully the GSO stack can be fully LCOified at which point the
 checksum offload semantics for a GSO skb will be the same as a regular
 skb.  As for TSO, if the driver/hw has enough information to do TSO, it
 must know where all the headers are, so it must be able to do the right
 checksum corrections on all of them.  (I think outer checksums are only
 affected by the Length and pseudo-header Length field changes.)
However, this does raise the question - will TSO be possible with nested
 encap?  And if not, will current drivers do the right thing in that case,
 or will they try to do encap TSO and only get two of the three layers?

-ed
