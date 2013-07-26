From: Adam Baker <linux@baker-net.org.uk>
Subject: Re: [PATCHv2] bridge: disable snooping if there is no querier
Date: Fri, 26 Jul 2013 23:19:00 +0100
Message-ID: <51F2F5D4.50409@baker-net.org.uk>
References: <1374757046-12463-1-git-send-email-linus.luessing@web.de> <1374760580-12920-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bridge@lists.linux-foundation.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Cong Wang <amwang@redhat.com>
To: =?UTF-8?B?TGludXMgTMO8c3Npbmc=?= <linus.luessing@web.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1374760580-12920-1-git-send-email-linus.luessing@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 25/07/13 14:56, Linus L=C3=BCssing wrote:
> If there is no querier on a link then we won't get periodic reports a=
nd
> therefore won't be able to learn about multicast listeners behind por=
ts,
> potentially leading to lost multicast packets, especially for multica=
st
> listeners that joined before the creation of the bridge.
>
> These lost multicast packets can appear since c5c23260594
> ("bridge: Add multicast_querier toggle and disable queries by default=
")
> in particular.
>
> With this patch we are flooding multicast packets if our querier is
> disabled and if we didn't detect any other querier.
>
> A grace period of the Maximum Response Delay of the querier is added =
to
> give multicast responses enough time to arrive and to be learned from
> before disabling the flooding behaviour again.
>
> Signed-off-by: Linus L=C3=BCssing<linus.luessing@web.de>

If the lack of queries if there is no other querier is unacceptable to=20
the majority of users (and I believe it is) then surely the sensible=20
option is to have the multicast querier toggle enabled by default.

The toggle was added in the first place because the queries were=20
reported to be generating issues with certain other equipment. This may=
=20
have been because the queries by default have an invalid IP address=20
(although I have been unable to identify what equipment they caused=20
problems with so can't verify this).

If the only reason to turn the querier off is because it interferes wit=
h=20
other equipment then the solution to it being off by default isn't to=20
generate queries in some instances even if it is off but rather to turn=
=20
it on by default and only turn it off if it causes problems. If=20
multicast_query_use_ifaddr was also enabled by default the the=20
likelihood of the querier causing problems elsewhere should be reduced.

Regards

Adam
