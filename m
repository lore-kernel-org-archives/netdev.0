From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [RFC v3 3/6] can: make struct proto const
Date: Tue, 15 Mar 2011 22:28:13 +0100
Message-ID: <4D7FD9ED.1080004@hartkopp.net>
References: <20110314132004.GA333@e-circ.dyndns.org> <20110314134721.GD333@e-circ.dyndns.org> <1300111755.3423.20.camel@edumazet-laptop> <20110314150227.GJ333@e-circ.dyndns.org> <1300120943.3423.121.camel@edumazet-laptop> <20110314171752.GL333@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: socketcan-core@lists.berlios.de, netdev@vger.kernel.org
To: Kurt Van Dijck <kurt.van.dijck@eia.be>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:41362 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756765Ab1COV2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 17:28:12 -0400
In-Reply-To: <20110314171752.GL333@e-circ.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14.03.2011 18:17, Kurt Van Dijck wrote:
> On Mon, Mar 14, 2011 at 05:42:23PM +0100, Eric Dumazet wrote:
>> Le lundi 14 mars 2011 =C3=A0 16:02 +0100, Kurt Van Dijck a =C3=A9cri=
t :
>>
>>> I see your point.
>>> The reason I modified this was, as described, checkpatch.pl was com=
plaining.
>>> Anyway, this sequence was protected by a spinlock 'proto_tab_lock'.
>>> I don't think it was a race.
>>>
>>> Did I miss something?
>>
>> As soon as proto_tab[proto] =3D cp; is done, another thread on anoth=
er cpu
>> can read the pointer and follow it.
>>
>> Hmm, I missed can_create() also uses the spinlock protection, so you=
're
>> probably right.
>>
>> It seems a bit overkill :(
>> phonet uses RCU for example.

Hello Eric,

the RCU code in phonet is worth to consider. But loading and removing o=
f
protocols is far away from being a hot path ... what would be the advan=
tages
to move to RCU here?

> I'll keep that in mind.
> Switching CAN protos to RCU is far beyond to goal of this patch :-)

Anyway making the struct proto a const (and set the default defines in =
the CAN
protocols) is a nice cleanup. Let's wait for the feedback about the RCU=
 from
Eric ... then this patch could be put into mainline independently from =
the
j1939 protocol.

Thanks,
Oliver
