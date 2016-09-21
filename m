From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH RFC 1/3] xdp: Infrastructure to generalize XDP
Date: Wed, 21 Sep 2016 10:42:34 +0200
Message-ID: <57E247FA.3020501@iogearbox.net>
References: <1474408824-418864-1-git-send-email-tom@herbertland.com>        <1474408824-418864-2-git-send-email-tom@herbertland.com>        <57E1CDE3.5030404@fb.com> <20160921083955.7cdba944@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
        netdev@vger.kernel.org, kernel-team@fb.com, tariqt@mellanox.com,
        bblanco@plumgrid.com, alexei.starovoitov@gmail.com,
        eric.dumazet@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>,
        Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48070 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751266AbcIUImn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 04:42:43 -0400
In-Reply-To: <20160921083955.7cdba944@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/21/2016 08:39 AM, Jesper Dangaard Brouer wrote:
> On Tue, 20 Sep 2016 17:01:39 -0700 Alexei Starovoitov <ast@fb.com> wrote:
>
>>   >  - Provides a more structured environment that is extensible to new
>>   >    features while being mostly transparent to the drivers
>>
>> don't see that in these patches either.
>> Things like packet size change (that we're working on) still
>> has to be implemented for every driver.
>> Existing XDP_TX, XDP_DROP have to be implemented per driver as well.
>>
>> Also introduction of xdp.h breaks existing UAPI.
>> That's not acceptable either.
>
> This response piss me off!@@#$
>
> We are the early stages of XDP development. Users cannot consider XDP a
> stable UAPI yet.  I added a big fat warning to the docs here[1].
>
> If you already consider this a stable API, then I will suggest that we
> disable XDP or rip the hole thing out again!!! Create a separate tree
> where we can cooperate on getting this right, before forcing this
> upstream.  I have raise concern about this several times upstream, but
> the patches got applied anyway, because you Alexei, promised this was
> super extendable and we could still change the APIs later. Maybe you
> tricked me?! I've started to look at the details, and I'm not happy with
> the extensibility.

I don't quite follow you here, Jesper. If you're talking about uapi-related
extensibility wrt struct xdp_md, then it's done the same way as done for tc
with 'shadow' struct __sk_buff. The concept of having this internal BPF insn
rewriter is working quite well for this, and it is extendable with new meta
data. Wrt return codes we're flexible to add new ones once agreed upon. The
whole XDP config is done via netlink, nested in IFLA_XDP container, so it can
be extended in future with other attrs, flags, etc, for setup and dumping.
The 'breakage' that was mentioned here was related to moving things into xdp.h.
It can be done and we did it similarly in the past with bpf_common.h, but
then really also bpf.h needs to include the new xdp.h header.
