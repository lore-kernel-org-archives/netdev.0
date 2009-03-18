From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCHv3] netns: oops in ip[6]_frag_reasm incrementing stats
Date: Wed, 18 Mar 2009 07:26:58 +0000
Message-ID: <20090318072658.GA4799@ff.dom.local>
References: <49BFAB7C.1020503@dti2.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: jorge@dti2.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:59335 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752462AbZCRH1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 03:27:06 -0400
Received: by fg-out-1718.google.com with SMTP id 13so54378fge.17
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2009 00:27:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <49BFAB7C.1020503@dti2.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-03-2009 14:54, Jorge Boncompte [DTI2] wrote:
> Jarek Poplawski escribi=F3:
>> On Tue, Mar 17, 2009 at 12:55:42PM +0100, Jorge Boncompte [DTI2] wro=
te:
>>> dev can be NULL in ip[6]_frag_reasm for skb's coming from RAW socke=
ts.
>>>
>>> Quagga's OSPFD sends fragmented packets on a RAW socket, when netfi=
lter
>>> conntrack reassembles them on the OUTPUT path you hit this code pat=
h.
>>>
>>> You can test it with something like "hping2 -0 -d 2000 -f AA.BB.CC.=
DD"
>>>
>>> Changes from v2: (address comments from Jarek Poplawski)
>>> 	- Patch reworked to get the net pointer with container_of()
>>> 	  instead of passing it to function calls.
>>> 	- Fix IPv6 code
>>> Changes from v1:
>>> 	- Fixed description
>> I guess David will be interested only with the final state of change=
s,
>> so v1 & v2 are not necessary here...
>>
>> Anyway, ipv4 looks OK to me, but ipv6 looks like something is
>> different:
>>> +	IP6_INC_STATS_BH(net, __in6_dev_get(dev), IPSTATS_MIB_REASMFAILS)=
;
>> It still depends on dev !=3D NULL in __in6_dev_get(). I see there
>> is also used skb->dst for similar things in ip6_frag_queue(), so I
>> don't know: it needs rethinking, and maybe these patches should be
>> separated if you prefer.
>=20
> 	Not my day! :-) I should not look at code at 2 am and write patches
> the day after, I confused _idev and idev in the check for !=3D NULL i=
n _DEVINC.
>=20
> 	I think this bug was first introduced by patch "[IPV6]: Per-interfac=
e
> statistics support." from YOSHIFUJI Hideaki on Nov 4, 2006.
>=20
> 	If someone with more knowledge could confirm that using something li=
ke...
>=20
> "(skb->dev ? skb->dev : skb->dst->dev)"
>=20
> ... here is fine I'll redo this part and resend. I do not have an IPv=
6 setup where
> I can test this.
>=20

skb->dst->dev is used in ip6_frag_queue anyway, so it shouldn't be
worse if you do this similarly in ip6_frag_reasm. If you send it as
a separate patch, and write it's not tested, David will decide if he
wants it. Otherwise you can resend this ipv4 patch only.

Jarek P.
