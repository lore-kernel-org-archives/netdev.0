From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH rfc] netfilter: two xtables matches
Date: Wed, 5 Dec 2012 16:50:23 -0500
Message-ID: <CA+FuTSd9ZKVo8HFdd_J0w9E+YR+prFeAHMLcQjR-=bcMb5DYHg@mail.gmail.com>
References: <1354735339-13402-1-git-send-email-willemb@google.com>
 <CA+FuTSeYvcdtNf7N=POD+RzsE01+WVsub6F_nqbn06RZyoWx8w@mail.gmail.com>
 <alpine.LNX.2.01.1212052100190.30908@nerf07.vanv.qr> <CA+FuTSfTVvQ8uBuSh47DRpShL5fyzNCaRXz39N1EaDqZCe8_+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CA+FuTSfTVvQ8uBuSh47DRpShL5fyzNCaRXz39N1EaDqZCe8_+A@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 5, 2012 at 4:45 PM, Willem de Bruijn <willemb@google.com> wrote:
> On Wed, Dec 5, 2012 at 3:00 PM, Jan Engelhardt <jengelh@inai.de> wrote:
>> On Wednesday 2012-12-05 20:28, Willem de Bruijn wrote:
>>
>>>Somehow, the first part of this email went missing. Not critical,
>>>but for completeness:
>>>
>>>These two patches each add an xtables match.
>>>
>>>The xt_priority match is a straighforward addition in the style of
>>>xt_mark, adding the option to filter on one more sk_buff field. I
>>>have an immediate application for this. The amount of code (in
>>>kernel + userspace) to add a single check proved quite large.
>>
>> Hm so yeah, can't we just place this in xt_mark.c?
>
> I'm happy to do so, but note that that breaks the custom of
> having one static struct xt_$NAME for each file xt_$NAME.[ch].
>
> It may be reasonable, as the same issue may keep popping up
> as additional sk_buff fields are found useful for filtering. For
> instance, skb->queue_mapping could be used in conjuction with
> network flow classification (ethtool -N).

bad example: queue_mapping is tx only. I thought of rxqueues.

> All the ancillary data
> accessible from BPF likely has some use and could be ported
> to iptables (rxhash, pkt_type, ...).
>
> To avoid rule explosion, I considered an xt_skbuff match rule that
> applies the same mask operation, range and inversion tests, and
> takes a field id to select the sk_buff field to operate on. I think
> the BPF patch is a better long term solution.
