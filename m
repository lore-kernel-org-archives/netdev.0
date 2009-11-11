From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] act_mirred: don't go back.
Date: Wed, 11 Nov 2009 16:44:48 +0800
Message-ID: <412e6f7f0911110044i22c28ab6pa3a3691c014e76a8@mail.gmail.com>
References: <4AF7B9F4.6010507@gmail.com> <1257751376.8009.2.camel@bigi>
	 <412e6f7f0911090031j16ab9c73o47f4d4d3ffd9be3a@mail.gmail.com>
	 <1257764086.6246.1.camel@bigi>
	 <412e6f7f0911090433j2b270663ycdf277110fbc6bac@mail.gmail.com>
	 <1257838834.3647.4.camel@bigi>
	 <412e6f7f0911100050k39920adfl1ab70e345269833a@mail.gmail.com>
	 <1257927097.4685.4.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:38268 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554AbZKKIon convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 03:44:43 -0500
Received: by pwi3 with SMTP id 3so564786pwi.21
        for <netdev@vger.kernel.org>; Wed, 11 Nov 2009 00:44:48 -0800 (PST)
In-Reply-To: <1257927097.4685.4.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 11, 2009 at 4:11 PM, jamal <hadi@cyberus.ca> wrote:
> Hi,
>
> On Tue, 2009-11-10 at 16:50 +0800, Changli Gao wrote:
>
>> Where? After skb2 is allocated, there won't be any failure any more.
>
>
> Sorry, yes, your change does look like an improvement.
> If you can test a little more - please add my sign-off and submit.

OK. I'll do some test first, then send it out for review.

>
>>
>> It's just OK. When using tc, I also found act_mirred doesn't support
>> ingress, then I realized that there isn't any difference between
>> ingress and egress, as it depends on its parent. However I do think =
it
>> is confused, when it prints:
>> filter parent ffff: protocol ip pref 49152 basic handle 0x1
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 action order 1: mirred (Egress Redirect =
to device ifb0) stolen
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 index 5 ref 1 bind 1.
>> And the TODO note still is in the source code of act_mirred, it do
>> make me wonder for a while!
>
> Well, you know if you have the energy - doing socket redirect would
> be very interesting indeed. Ingress is another beast, it requires som=
e
> thinking and a lot more testing depending on the devices because of
> possible loops.
>

The current kernel and iproute2 support ingress in another way, that
is attaching the filter to the corresponding ingress qdisc. refter to
http://www.linuxfoundation.org/en/Net:IFB . The loops is avoided in
netif_receive_skb() and with TTL mechanism. Do you have more
documentation or examples about socket redirect? Sorry, I don't know
what it is used to do. Is it sth. like ipt_REDIRECT?


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
