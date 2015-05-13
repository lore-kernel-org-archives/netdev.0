From: Tom Herbert <tom@herbertland.com>
Subject: Re: [patch net-next v3 00/15] introduce programable flow dissector
 and cls_flower
Date: Wed, 13 May 2015 15:27:59 -0400
Message-ID: <CALx6S36XpD7VjygyfG1mRpX3xgHyXjDQQYU8tBRCjuRgckQasQ@mail.gmail.com>
References: <1431435381-7164-1-git-send-email-jiri@resnulli.us>
	<20150513.152102.606157874586561609.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Thomas Graf <tgraf@suug.ch>, jesse@nicira.com,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	alexander.h.duyck@redhat.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Alexei Starovoitov <ast@plumgrid.com>, daniel@iogearbox.net,
	Herbert Xu <herbert@gondor.apana.org.au>,
	cwang@twopensource.com, john fastabend <john.fastabend@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:35589 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753207AbbEMT17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 15:27:59 -0400
Received: by igbyr2 with SMTP id yr2so148350644igb.0
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 12:27:59 -0700 (PDT)
In-Reply-To: <20150513.152102.606157874586561609.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 13, 2015 at 3:21 PM, David Miller <davem@davemloft.net> wrote:
> From: Jiri Pirko <jiri@resnulli.us>
> Date: Tue, 12 May 2015 14:56:06 +0200
>
>> Per Davem's request, I prepared this patchset which introduces programmable
>> flow dissector. For current users of flow_keys, there is a wrapper
>> skb_flow_dissect_flow_keys which maintains the previous behaviour.
>> For purposes of cls_flower, couple of new dissection keys were introduced.
>>
>> Note that this dissector can be also eventually used by openvswitch code.
>>
>> Also, as a next step, I plan to get rid of *skb_flow_get_ports(export)
>> and *__skb_get_poff as their functionality can be now implemented by
>> skb_flow_dissect as well.
>>
>> v2->v3:
>> - remove TCA_FLOWER_POLICE attr suggested by Jamal
>>
>> v1->v2:
>> - move __skb_tx_hash rather to dev.c as suggested by Alex
>
> Ok, assuming this passes all of my build tests, I'll push this into
> net-next.
>
> I'm sure there will be some performance improvements possible, and I
> hope you will look into making sure this new programmable classifier
> is as light weight as possible.
>
> Anyways, thanks a lot.

David,

I still have concerns about making flow_dissector more complex like
this. This still seems like it should this programmable logic be done
in a separate function. We call flow_dissector at least once per
packet via skb_get_hash, it is in the critical path, and adding
several conditionals can only slow it down and provides no new value
to skb_get_hash. At the very least can we at least get some
performance numbers to show impact of this?

Thanks,
Tom
