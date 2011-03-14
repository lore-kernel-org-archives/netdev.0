From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 1/4] netfilter: xt_connlimit: fix daddr connlimit in SNAT scenario
Date: Tue, 15 Mar 2011 07:49:04 +0800
Message-ID: <AANLkTimBV9x7Y-tUez5VMDoU+8mtaw1f48GV1yxgZ71c@mail.gmail.com>
References: <1300085414-27275-1-git-send-email-xiaosuo@gmail.com>
 <alpine.LNX.2.01.1103141310140.27542@obet.zrqbmnf.qr> <AANLkTi=QgVBVAPcTmb_La=VJOLq5LmGPqMfw7bbCuByP@mail.gmail.com>
 <alpine.LNX.2.01.1103141955180.21929@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1103141955180.21929@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 15, 2011 at 3:00 AM, Jan Engelhardt <jengelh@medozas.de> wr=
ote:
> On Monday 2011-03-14 13:42, Changli Gao wrote:
>
>>
>>Yes, you are correct only when there is no SNAT rule. If there is an
>>SNAT rule:
>>
>>-t nat -A POSTROUTING -p tcp --dport 80 -j SNAT --to-source 192.168.0=
=2E1
>>
>>the final tuples will be:
>>src =3D home dst =3D router src=3D1.2.3.4 dst=3D192.168.0.1
>>
>>However, the tuple saved by connlimit is src=3D1.2.3.4 dst=3Dhome, so=
 this
>>conn will be removed later as there isn't any conntrack, which has
>>this tuple in any direction.
>
> But I don't yet see how your patch #1 can help. At the time
> conn->tuple=A0=3D *tuple is done, *tuple still contains the non-SNATe=
d
> tuple, and it is never updated again.
>

In this patch, conn->addr is used to save the destination/source
address instead of conn->tuple.src.u3, so the conn->tuple is used for
conntrack lookup only. Just as the original tuple isn't updated, we
can use it to looking up the associated conntrack all the time.

addr: 192.168.0.1
tuple: src =3D home, dst =3D router

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
