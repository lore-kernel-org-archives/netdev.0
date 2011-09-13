From: Gao feng <omarapazanadi@gmail.com>
Subject: Re: pskb_copy() in tcp_transmit_skb()
Date: Tue, 13 Sep 2011 20:00:19 +0800
Message-ID: <4E6F45D3.50306@gmail.com>
References: <201109131221.37561.christoph.paasch@uclouvain.be> <4E6F2275.2050902@cn.fujitsu.com> <201109131355.55588.christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:52560 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753198Ab1IMMbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2011 08:31:31 -0400
Received: by ywb5 with SMTP id 5so386855ywb.19
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2011 05:31:30 -0700 (PDT)
In-Reply-To: <201109131355.55588.christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 11-9-13 =E4=B8=8B=E5=8D=886:55, Christoph Paasch =E5=86=99=E9=
=81=93:
> Hi,
>
> On Tuesday 13 September 2011 wrote Gaofeng:
>>> I'm trying to understand the reason for the possible call to pskb_c=
opy()
>>> in tcp_transmit_skb().
>>> I don't find, where we may have a cloned skb entering tcp_transmit_=
skb().
>>>
>>> The original pskb_copy() came from tcp_retransmit_skb() (commit
>>> dfb4b9dceb35c567a595ae5e9d035cfda044a103).
>>> But from that point, the git-history does not show where the pskb_c=
opy()
>>> is coming from.
>>>
>>>
>>> Does somebody has an idea, how a cloned skb can be passed to
>>> tcp_transmit_skb() and thus trigger this call to pskb_copy().
>>
>> maybe nat,nat can change the tcp packet header
>
> although NAT may change the TCP header, it is not doing an skb_clone(=
) - (at
> least I don't find it).
> Thus, we will not call pskb_copy() in tcp_transmit_skb() due to NAT.
>
> Christoph
>
> --
> Christoph Paasch
> PhD Student
>
> IP Networking Lab --- http://inl.info.ucl.ac.be
> MultiPath TCP in the Linux Kernel --- http://inl.info.ucl.ac.be/mptcp
> Universit=C3=A9 Catholique de Louvain
>
> www.rollerbulls.be
> --
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
maybe this.
if the nic driver has not transmit the cloned skb to the network yet.
then tcp_retransmit_skb is called by some logical.
if dont use pskb_copy here,it will make the nat or some header operatio=
n=20
error.
