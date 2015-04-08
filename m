From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v2 net-next 2/2] tc: make ingress and egress qdiscs consistent
Date: Wed, 08 Apr 2015 07:47:34 -0400
Message-ID: <55251556.4040900@mojatatu.com>
References: <1428455025-5945-1-git-send-email-ast@plumgrid.com> <1428455025-5945-2-git-send-email-ast@plumgrid.com> <20150407.223549.335906307265617841.davem@davemloft.net> <55249EFA.5040405@plumgrid.com> <5524B339.1070403@plumgrid.com> <5524E878.7070803@iogearbox.net> <20150408090520.GA2057@nanopsycho.orion> <552508E8.5050203@iogearbox.net> <55250D92.6030702@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	tgraf@suug.ch
To: Daniel Borkmann <daniel@iogearbox.net>,
	Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:33740 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753559AbbDHLrh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 07:47:37 -0400
Received: by ignm3 with SMTP id m3so27602475ign.0
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 04:47:36 -0700 (PDT)
In-Reply-To: <55250D92.6030702@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Should have read my emails backward. Refer to my other email
So why are you not able to use the indicators of where in the stack
you are in both actions and classifiers?
bpf needs to adjust.

cheers,
jamal

On 04/08/15 07:14, Daniel Borkmann wrote:
> On 04/08/2015 12:54 PM, Daniel Borkmann wrote:
>> On 04/08/2015 11:05 AM, Jiri Pirko wrote:
>
> Generically adjusting egress towards ingress would not work. I
> think it's reasonable to assume that the majority of people use
> classifier and actions only from egress side, and they rely on
> having l2 context present. Stripping that away would also be an
> artificial limitation we'd impose.
>
> You could use the ingress qdisc to redirect traffic to an ifb
> device and attach the same egress classifier and action there
> as skb_pull(skb, skb->dev->hard_header_len) is being done, but
> I'd presume that extra detour is pretty slow. To make this useful,
> we'd need a very lightweight solution.
>
>>> having more ingres queue disk. Would be just confusing.
>>
>> I'm all for it, that's what I've mentioned earlier in this thread
>> already. ;) The above would be one possibility, but of course I'm
>> open for other, better suggestions?
>>
>> I totally agree with Dave that skb_share_check() should be avoided
>> at all costs. At least on my laptop (maybe not a perfect example),
>> I've got these as packet socket users present in the background,
>> so there are packet users running all the time where we would hit
>> skb_share_check() then:
>>
>> # ss -0lnp
>> Netid  State      Recv-Q Send-Q      Local Address:Port    Peer
>> Address:Port
>> p_raw  UNCONN     0      0                *:wlp2s0b1       *
>> users:(("dhclient",1290,5))
>> p_dgr  UNCONN     0      0          [34958]:wlp2s0b1       *
>> users:(("wpa_supplicant",805,13))
>> p_dgr  UNCONN     0      0              [0]:*              *
>> users:(("wpa_supplicant",805,12))
>>
>> I do not yet see a generic way to push an offset down into various
>> classifiers and actions that otherwise don't really work with ingress,
>> it's not just limited to BPF only as Alexei already mentioned. Hm.
>>
>> Cheers,
>> Daniel
