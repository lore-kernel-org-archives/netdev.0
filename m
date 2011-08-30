From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 18/24] sctp: Remove unnecessary OOM logging messages
Date: Mon, 29 Aug 2011 18:21:21 -0700
Message-ID: <1314667281.6852.47.camel@Joe-Laptop>
References: <cover.1314650069.git.joe@perches.com>
	 <21b4d996c8861373ac77d427914ec7882fe0c83e.1314650069.git.joe@perches.com>
	 <1314654209.2563.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:46379 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751775Ab1H3BVX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Aug 2011 21:21:23 -0400
In-Reply-To: <1314654209.2563.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-08-29 at 23:43 +0200, Eric Dumazet wrote:
> Le lundi 29 ao=C3=BBt 2011 =C3=A0 14:17 -0700, Joe Perches a =C3=A9cr=
it :
> > Removing unnecessary messages saves code and text.
> > Site specific OOM messages are duplications of a generic MM
> > out of memory message and aren't really useful, so just
> > delete them.
> > Signed-off-by: Joe Perches <joe@perches.com>
> > ---
> >  net/sctp/protocol.c |    3 ---
> >  1 files changed, 0 insertions(+), 3 deletions(-)
> > diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
[]
> > @@ -1326,7 +1326,6 @@ SCTP_STATIC __init int sctp_init(void)
> >  			__get_free_pages(GFP_ATOMIC|__GFP_NOWARN, order);
> >  	} while (!sctp_assoc_hashtable && --order > 0);
> >  	if (!sctp_assoc_hashtable) {
> > -		pr_err("Failed association hash alloc\n");
> >  		status =3D -ENOMEM;
> >  		goto err_ahash_alloc;
> >  	}
[]
> > @@ -1359,7 +1357,6 @@ SCTP_STATIC __init int sctp_init(void)
> >  			__get_free_pages(GFP_ATOMIC|__GFP_NOWARN, order);
> >  	} while (!sctp_port_hashtable && --order > 0);
> >  	if (!sctp_port_hashtable) {
> > -		pr_err("Failed bind hash alloc\n");
> >  		status =3D -ENOMEM;
> >  		goto err_bhash_alloc;
> >  	}
> It would be nice if you could avoid all these patches, that you dont
> even read.

Didn't read is not the same thing as didn't notice.

> As I already told you in the past, __GFP_NOWARN dont print generic OO=
M
> messages.

I didn't notice those had GFP_NOWARN.

> Its not because I told Wang Shaoyan not adding a useless "pr_err("Out=
 of
> memory\n");" in last gianfar patch, that you have to remove all
> messages, with one hundred or more patches.

> If I remember well, you even disagreed at that time.

No, what I said was that it'd be better to get agreement
to delete them before deleting them.

https://lkml.org/lkml/2011/8/9/379

So I submitted an RFC and cc'd you.
You did not reply.

https://lkml.org/lkml/2011/8/25/580

> Furthermore, a failed vmalloc() is not guaranteed to emit an OOM
> message, is it ?

Doesn't seem to be, perhaps it should be
when __GFP_NOWARN is not set...
