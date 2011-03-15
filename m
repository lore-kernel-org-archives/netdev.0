From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 1/4] netfilter: xt_connlimit: fix daddr connlimit in SNAT scenario
Date: Tue, 15 Mar 2011 09:30:04 +0800
Message-ID: <AANLkTinZiVbVttzNuGdShC25=BtwJUzhSX_YZBxAr+qF@mail.gmail.com>
References: <1300085414-27275-1-git-send-email-xiaosuo@gmail.com>
 <alpine.LNX.2.01.1103141310140.27542@obet.zrqbmnf.qr> <AANLkTi=QgVBVAPcTmb_La=VJOLq5LmGPqMfw7bbCuByP@mail.gmail.com>
 <alpine.LNX.2.01.1103141955180.21929@obet.zrqbmnf.qr> <AANLkTimBV9x7Y-tUez5VMDoU+8mtaw1f48GV1yxgZ71c@mail.gmail.com>
 <alpine.LNX.2.01.1103150210370.21929@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1103150210370.21929@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 15, 2011 at 9:16 AM, Jan Engelhardt <jengelh@medozas.de> wr=
ote:
>
>
> The original tuple may not be updated, but the reply tuple is.
> And we are taking the reply tuple in
>
> =A0 =A0 =A0 =A0tuple_ptr =3D &ct->tuplehash[IP_CT_DIR_REPLY].tuple;
>
> which is subsequently copied to conn->tuple on the first invocation.
>
> Afterwards, SNAT will update ct->tuplehash[reply].tuple, and so
> conn->tuple is outdated. Calling nf_conntrack_find_get(conn->tuple)
> in count_them would then fail, would it not?
>

After my patch, tuple is only used to look up the corresponding
conntrack. And as you know, one conntrack has two tuples, you can look
up a conntrack by either one. The old implementation uses the
conn->tuple.src.u3 to save target address, so you need to use the
reply tuple to work around the DNAT issue. In my patch, the target
address isn't saved in conn->tuple.src.u3 but in conn->addr, so we can
use the constant tuple in the original direction to look up the
corresponding conntrack in count_them(). No reply tuple involved, no
failed nf_conntrack_find_get().

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
