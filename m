From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [patch net-next-2.6 v2] net: vlan: make non-hw-accel rx path
 similar to hw-accel
Date: Sun, 22 May 2011 12:04:50 +0200
Message-ID: <BANLkTimCsXx4Gb7HoCT51k=ThPNXdjuOEw@mail.gmail.com>
References: <BANLkTinZUATEjBij+rwBTn=n-Tau5qHPWw@mail.gmail.com>
 <4DD7BB61.9050200@gmail.com> <BANLkTinqFJa-B7E7tonzOKGV4etZHUkUug@mail.gmail.com>
 <4DD87C25.4030701@gmail.com> <20110522062915.GA2611@jirka.orion>
 <m17h9jp7js.fsf@fess.ebiederm.org> <4DD8CA87.8040905@gmail.com>
 <BANLkTi=B4c-A9ZC2apE+ZOQmgdzaJb0oEQ@mail.gmail.com> <4DD8D2FE.4080204@gmail.com>
 <BANLkTimQ6LAWbZMCjBhqA5By8jvxwnfjVg@mail.gmail.com> <20110522093614.GB2611@jirka.orion>
 <4DD8DD06.6070202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jesse Gross <jesse@nicira.com>,
	Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net
To: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:37756 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751895Ab1EVKFL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 06:05:11 -0400
Received: by qwk3 with SMTP id 3so2418186qwk.19
        for <netdev@vger.kernel.org>; Sun, 22 May 2011 03:05:10 -0700 (PDT)
In-Reply-To: <4DD8DD06.6070202@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/22 Nicolas de Peslo=FCan <nicolas.2p.debian@gmail.com>:
> Le 22/05/2011 11:36, Jiri Pirko a =E9crit :
>> Sun, May 22, 2011 at 11:20:09AM CEST, mirqus@gmail.com wrote:
>>> W dniu 22 maja 2011 11:10 u=BFytkownik Nicolas de Peslo=FCan
>>> <nicolas.2p.debian@gmail.com> =A0napisa=B3:
>>>> Le 22/05/2011 10:52, Micha=B3 Miros=B3aw a =E9crit :
>>>>> I assumed that this untaging Jiri is implementing does not remove=
 the
>>>>> tag. It moves the information from skb->data to skb->vlan_tci, bu=
t the
>>>>> information contained is not otherwise changing. All your example=
s
>>>>> should work regardless of where the tag is stored.
>>>> I assumed (but didn't tested) that this untagging also change the
>>>> starting
>>>> point of the payload of the packet. So protocol handlers expecting=
 to
>>>> have
>>>> the raw packet won't see the vlan header.
>>> That would also be the case with hardware stripped tags - they need=
 to
>>> look into skb->vlan_tci anyway.
>> Exactly. Nicolas, I do not see anything wrong on always untagging in=
 all
>> your setups. As Michal said, vlan_tci keeps the info.
>
> I understand this.
>
> But I don't understand how the bridge code is expected to know whethe=
r it
> should re-tag the packet or not before forwarding and which value to =
use as
> the egress vlan tag.
>
> 1/ eth0 - br0 - eth1 : the bridge is expected to retag using skb->vla=
n_tci
> value.
>
> 2/ eth0 - eth0.100 - br0 - eth1.200 - eth1 : the bridge is expected t=
o retag
> using a different value than skb->vlan_tci.

> 3/ eth0 - eth0.100 - br0 - eth1 : the bridge is expected not to re-ta=
g,
> because the expected behavior of this setup is to untag while crossin=
g the
> bridge.
>
> 4/ eth0 - eth0.100 - eth0.100.300 - br0 - eth1.400 - eth1.200 - eth1 =
: the
> bridge is expected to retag using a different value than skb->vlan_tc=
i. What
> value would skb->vlan_tci hold when the skb will be delivered to the =
bridge?
> 100 or 300?
>
> From my point of view, in both setup, the bridge will receive a singl=
e value
> in skb->vlan_tci and will lack any other indication to help it decide=
 how to
> retag when forwarding.

Packets looking like they came from eth0.100 will have skb->vlan_tci
cleared (like taking packet out of a tunnel) and then possibly filled
again with inner tag. It's really convenient to thing of VLANs as
tunnels.

Best Regards,
Micha=B3 Miros=B3aw
