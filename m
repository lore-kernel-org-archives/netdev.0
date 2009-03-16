From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCHv2] netns: oops in ip_frag_reasm incrementing stats
Date: Mon, 16 Mar 2009 23:05:26 +0100
Message-ID: <20090316220526.GA3051@ami.dom.local>
References: <49BA87F4.1090709@dti2.net> <49BA8B65.2060408@dti2.net> <49BE4192.7090706@dti2.net> <49BEBF25.70008@gmail.com> <49BECA4A.4080207@dti2.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f176.google.com ([209.85.220.176]:46106 "EHLO
	mail-fx0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751007AbZCPWGt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2009 18:06:49 -0400
Received: by fxm24 with SMTP id 24so3688514fxm.37
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2009 15:06:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <49BECA4A.4080207@dti2.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 16, 2009 at 10:53:14PM +0100, Jorge Boncompte [DTI2] wrote:
> Jarek Poplawski escribi=F3:
>> Jorge Boncompte [DTI2] wrote, On 03/16/2009 01:09 PM:
>>
>>> dev can be NULL on ip_frag_reasm for skb's coming from RAW sockets.
>>>
>>> Quagga's OSPFD sends fragmented packets on a RAW socket, when netfi=
lter
>>> conntrack reassembles them on the OUTPUT path you hit this code pat=
h.
>>>
>>> Changes from v1:
>>>    - Fixed description
>>>
>>> Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
>>> ---
>>> net/ipv4/ip_fragment.c |   14 +++++++-------
>>> 1 files changed, 7 insertions(+), 7 deletions(-)
>>>
>>> diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
>>> index 6659ac0..8f150d5 100644
>>> --- a/net/ipv4/ip_fragment.c
>>> +++ b/net/ipv4/ip_fragment.c
>>
>> ...
>>
>>> -static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
>>> +static int ip_frag_reasm(struct net *net, struct ipq *qp, struct s=
k_buff *prev,
>>> 			 struct net_device *dev)
>>> {
>>> 	struct iphdr *iph;
>>> @@ -548,7 +548,7 @@ static int ip_frag_reasm(struct ipq *qp, struct=
 sk_buff *prev,
>>> 	iph =3D ip_hdr(head);
>>> 	iph->frag_off =3D 0;
>>> 	iph->tot_len =3D htons(len);
>>> -	IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_REASMOKS);
>>> +	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMOKS);
>>
>>
>> I didn't check this but isn't something like this possible here too?=
:
>>
>> static inline int ip_frag_too_far(struct ipq *qp)
>> {
>> 	...
>>         net =3D container_of(qp->q.net, struct net, ipv4.frags);
>>         IP_INC_STATS_BH(net, IPSTATS_MIB_REASMFAILS);
>>
>
> 	Yes, it seems so. I did not noticed how the rest of the code accesse=
d
> the net pointer, sorry.
> 	Do you want to send a patch yourself or should I do it?
>

You did the whole work so I hope you'll finish this (after checking
and maybe some testing)!

Regards,
Jarek P.
