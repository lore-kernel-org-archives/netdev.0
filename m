From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net: check the length of the data before dereferencing it
Date: Mon, 2 Apr 2012 11:45:05 +0800
Message-ID: <CABa6K_HfWckb=sv7oQatv2ZJm3EKJE0mutQQ-OiddXiR6E7eHg@mail.gmail.com>
References: <1333336250-4110-1-git-send-email-xiaosuo@gmail.com>
 <1333336773.2325.6531.camel@edumazet-glaptop> <20120401.232942.1829187970291547571.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, kaber@trash.net, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120401.232942.1829187970291547571.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 2, 2012 at 11:29 AM, David Miller <davem@davemloft.net> wro=
te:
>
> Tag Eric, you're it.
>
> You ACK'd this patch, so you get to show how this is actually able
> to cause some kind of problem.
>
> I assert that this is adding a useless test, that doesn't fix any kin=
d
> of possible crash or misbehavior. =A0If length =3D=3D 1 at the defaul=
t:, the
> code will absolutely do the right thing.
>
> Prove me wrong.

Thinking about a malformed tcp segment, which has no data but silly
options, and whose last byte is neither TCPOPT_EOL or TCPOPT_NOP, we
will try to dereference one byte over the boundary when parsing the
options. I know we have skb_shared_info at the end and it won't cause
any crash, but should we rely on this fact?

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
