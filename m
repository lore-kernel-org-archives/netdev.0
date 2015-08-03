From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] ebpf: add skb->hash to offset map for usage in
 {cls,act}_bpf or filters
Date: Sun, 2 Aug 2015 23:16:12 -0700
Message-ID: <55BF072C.3000302@plumgrid.com>
References: <4b25d0b28e9c366a8a307d855d1690038956e6bd.1438382433.git.daniel@iogearbox.net>
 <CALx6S35Xw-14Z8=w2cg7dFFzfkEmkjuqU=37uG3Tb-OoW2JEoA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:32960 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801AbbHCGQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 02:16:14 -0400
Received: by padck2 with SMTP id ck2so81820417pad.0
        for <netdev@vger.kernel.org>; Sun, 02 Aug 2015 23:16:14 -0700 (PDT)
In-Reply-To: <CALx6S35Xw-14Z8=w2cg7dFFzfkEmkjuqU=37uG3Tb-OoW2JEoA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/2/15 6:09 PM, Tom Herbert wrote:
>> I was thinking whether to add skb_get_hash(), but then concluded the
>> >raw skb->hash seems fine in this case: we can directly access the hash
>> >w/o extra eBPF helper function call, it's filled out by many NICs on
>> >ingress, and in case the entropy level would not be sufficient, people
>> >can still implement their own specific sw fallback hash mix anyway.
>> >
> Maybe we should add the skb_get_hash also? It doesn't as useful if
> some scenarios we get a valid hash and in others not.

we also discussed whether it makes sense to expose l4_hash and sw_hash
bits as well. imo, seems a bit of overkill, since such call into sw hash
function like this exposes the logic of flow_dissector looking into
inner header. There are pros and cons. I think if we expose
flow_dissector it's cleaner to do it directly (instead of skb_get_hash).
Alternatively we can obfuscate skb_get_hash by calling it
'please compute some a hash on a packet somehow', but that will be
awkward to use. The programs can compute whatever hash they like anyway.
