From: Alex Gartrell <alexgartrell@gmail.com>
Subject: Re: Why return E2BIG from bpf map update?
Date: Tue, 21 Jul 2015 03:13:27 -0700
Message-ID: <CALCkm3ck95Py=vPq+fWrcps=EVwtgFhDvGGyfoZ0AkLraaZJNA@mail.gmail.com>
References: <CALCkm3eCUYFOon6Gza4A8Ske8MS1rVFJJip_J9dWQp79ju8zBw@mail.gmail.com>
 <55AD7514.7040906@plumgrid.com> <55AE1374.6010608@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:35567 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751997AbbGUKNr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 06:13:47 -0400
Received: by qgii95 with SMTP id i95so54035675qgi.2
        for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 03:13:46 -0700 (PDT)
In-Reply-To: <55AE1374.6010608@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 21, 2015 at 2:40 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 07/21/2015 12:24 AM, Alexei Starovoitov wrote:
>>
>> On 7/20/15 3:15 PM, Alex Gartrell wrote:
>>>
>>> The ship has probably sailed on this one, but it seems like ENOSPC
>>> makes more sense than E2BIG.  Any chance of changing it so that poor
>>> ebpf library maintainers in the future don't have to wonder how their
>>> argument list got too big?
>>
>>
>> sorry, too late.
>> It's in tests and even document in bpf manpage:
>> "E2BIG - indicates that the number of elements in the map reached the
>> max_entries limit specified at map creation time."
>> I read E2BIG as "too big" and not as "argument list is too long" :)
>
>
> If some libraries do an strerror(3) on errno then it certainly sounds
> a bit weird, "no space left on device" perhaps also a bit misleading.
> The bpf(2) manpage was actually submitted/discussed longer time ago,
> but I still didn't see it in Michael's tree yet, will ping him again.

I was just being whiny :)

The options really are
ENOMEM -- really should mean allocation failed
E2BIG -- really should mean argument list too big
ENOSPC -- really should mean that a physical device is full

I suppose there's also
EDQUOT -- Disk Quota Exceeded

And if you're really stretching
EXFULL - Exchange Full

but I've never seen either of the last two in my life.

So clearly this is all very subjective and people who complain about
it on mailing lists (me) are the worst.

The only complaint I'd have though is E2BIG actually does mean that
your bpf_attr argument is too big as well, so that part confused me
for a couple of minutes.  But, the EINVAL errno has similarly been
abused to death so I don't think it's that big of a deal.

/bikeshedding

-- 
Alex Gartrell <agartrell@fb.com>
