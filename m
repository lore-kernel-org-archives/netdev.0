From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCHv4 net-next] xfrm: Namespacify xfrm_policy_sk_bundles
Date: Wed, 25 Dec 2013 14:40:36 +0800
Message-ID: <52BA7DE4.9070404@windriver.com>
References: <1387337658-28951-1-git-send-email-fan.du@windriver.com> <1387342211.19078.295.camel@edumazet-glaptop2.roam.corp.google.com> <52B24D7D.6060902@windriver.com> <1387419308.19078.343.camel@edumazet-glaptop2.roam.corp.google.com> <52B26553.9070103@windriver.com> <1387424650.19078.355.camel@edumazet-glaptop2.roam.corp.google.com> <52B3BAD1.30205@windriver.com> <20131224103521.GB29716@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	<timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:43581 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956Ab3LYGlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Dec 2013 01:41:21 -0500
In-Reply-To: <20131224103521.GB29716@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ccing Timo

On 2013=E5=B9=B412=E6=9C=8824=E6=97=A5 18:35, Steffen Klassert wrote:
> On Fri, Dec 20, 2013 at 11:34:41AM +0800, Fan Du wrote:
>>
>> Subject: [PATCHv4 net-next] xfrm: Namespacify xfrm_policy_sk_bundles
>>
>> xfrm_policy_sk_bundles, protected by net->xfrm.xfrm_policy_sk_bundle=
_lock
>> should be put into netns xfrm structure, otherwise xfrm_policy_sk_bu=
ndles
>> can be corrupted from different net namespace.
>
> I'm ok with this patch, but I wonder where we use these cached socket
> bundles. After a quick look I see where we add and where we delete
> them, but I can't see how we use these cached bundles.

Interesting

The per socket bundles is introduced by Timo in commit 80c802f3
("xfrm: cache bundles instead of policies for outgoing flows")

But one fundamental question is why not use existing flow cache
for per socket bundles as well? then no need to create such per
sock xdst for every packet, and also share the same flow cache
flush mechanism.

My first impression is it can be done this way, I'm going to head
this way unless turn out otherwise.

So Timo ?

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
