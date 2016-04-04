From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC PATCH 4/5] mlx4: add support for fast rx drop bpf program
Date: Mon, 04 Apr 2016 11:57:52 +0200
Message-ID: <57023AA0.5080600@iogearbox.net>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>	 <1459560118-5582-5-git-send-email-bblanco@plumgrid.com>	 <1459622455.18188.5.camel@sipsolutions.net>	 <20160403063834.GE21980@gmail.com> (sfid-20160403_083840_887646_8335D97B) <1459755310.18188.13.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, tom@herbertland.com,
	alexei.starovoitov@gmail.com, ogerlitz@mellanox.com,
	john.fastabend@gmail.com, brouer@redhat.com
To: Johannes Berg <johannes@sipsolutions.net>,
	Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60365 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751885AbcDDJ54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 05:57:56 -0400
In-Reply-To: <1459755310.18188.13.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/04/2016 09:35 AM, Johannes Berg wrote:
> On Sat, 2016-04-02 at 23:38 -0700, Brenden Blanco wrote:
>>
>> Having a common check makes sense. The tricky thing is that the type can
>> only be checked after taking the reference, and I wanted to keep the
>> scope of the prog brief in the case of errors. I would have to move the
>> bpf_prog_get logic into dev_change_bpf_fd and pass a bpf_prog * into the
>> ndo instead. Would that API look fine to you?
>
> I can't really comment, I wasn't planning on using the API right now :)
>
> However, what else is there that the driver could possibly do with the
> FD, other than getting the bpf_prog?
>
>> A possible extension of this is just to keep the bpf_prog * in the
>> netdev itself and expose a feature flag from the driver rather than
>> an ndo. But that would mean another 8 bytes in the netdev.
>
> That also misses the signal to the driver when the program is
> set/removed, so I don't think that works. I'd argue it's not really
> desirable anyway though since I wouldn't expect a majority of drivers
> to start supporting this.

I think ndo is probably fine for this purpose, see also my other mail. I
think currently, the only really driver specific code would be to store
the prog pointer somewhere and to pass needed meta data to populate the
fake skb.

Maybe mid-term drivers might want to reuse this hook/signal for offloading
as well, not yet sure ... how would that relate to offloading of cls_bpf?
Should these be considered two different things (although from an offloading
perspective they are not really). _Conceptually_, XDP could also be seen
as a software offload for the facilities we support with cls_bpf et al.

Thanks,
Daniel
