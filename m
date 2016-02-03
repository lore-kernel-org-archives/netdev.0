From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net] net: Allow flow dissector to handle non 4-byte
 aligned headers
Date: Wed, 3 Feb 2016 09:51:36 -0800
Message-ID: <CALx6S37g57kSvvXQy2oY5uMixOw5t-Q2dRTRhGSYS0P=i-ff-A@mail.gmail.com>
References: <1454276221-3543907-1-git-send-email-tom@herbertland.com>
	<20160202003127.GA25154@oracle.com>
	<CALx6S34MGwp2m=QmfQ36tWnaWbFXvMG63sj7Nz1KgMtegxn-2A@mail.gmail.com>
	<20160203173125.GA14627@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:36948 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933336AbcBCRvh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 12:51:37 -0500
Received: by mail-ig0-f179.google.com with SMTP id 5so42407794igt.0
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 09:51:37 -0800 (PST)
In-Reply-To: <20160203173125.GA14627@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 3, 2016 at 9:31 AM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (02/03/16 09:07), Tom Herbert wrote:
>> > Kernel unaligned access at TPC[9150dc] ipv4_neigh_lookup+0x38/0x170
>>
>> Sowmini,
>>
>> This doesn't look like a hard crash to me. Instead of trying to fix
>> all the alignment issues for Sparc, can we just take the trap, fix up
>> the load, and continue without any further fuss? Performance might
>> suffer, but it doesn't seem like the bad alignments are happening in
>> critical paths.
>>
>
> None of these things is a hard crash, but they are
>
> (a) quite noisy

Try disabling the crash dump. That will improve performance.

> (b) I'm able to generate alignment falls merely by configuring
>     tunnels, and it gets worse when I disable RSS and use RFS/RPS
>     instead. So "critical path" might need some definition.

But as we said it's only for tunnels that specifically encapsulate an
ethernet header with aligning it. Many other encapsulations (e.g.
IPIP, GUE, EtherIP,IP/GRE) should be fine. We could take this to IETF
and point out that alignment is still relevant in protocol
development. We can't fix this for GRE or VXLAN at this point, but
maybe there's still hope for VXLAN-GPE or Geneve...

> (c) a perf risk for other platforms as well, even when they dont
>     complain noisily about it.
>
Right, but there is a big difference between a performance degradation
and a hard failure. It would at least be nice to know what the
performance hit actually is, if it's acceptable then this would be a
far simpler and much less invasive fix than the alternatives.

Thanks,
Tom

> --Sowmini
