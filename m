From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC PATCH 8/8] [PKTGEN]: uninline getCurUs
Date: Mon, 14 Jan 2008 10:33:34 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0801140952100.31652@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0801121420220.19333@kivilampi-30.cs.helsinki.fi>
 <20080112.202414.192104180.davem@davemloft.net>
 <Pine.LNX.4.64.0801140920580.31652@kivilampi-30.cs.helsinki.fi>
 <20080113.235113.170762359.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-921463403-1200299614=:31652"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:52367 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752664AbYANIdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 03:33:38 -0500
In-Reply-To: <20080113.235113.170762359.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-921463403-1200299614=:31652
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Sun, 13 Jan 2008, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Mon, 14 Jan 2008 09:43:08 +0200 (EET)
> 
> > I'd prefer sending them as iso-8859-1 compliant (and I guess you are able 
> > to test your fix-to-utf-8 machinery with it as well :-)), as it would also 
> > make my mails compatible with other people's git apply tools you're not 
> > using (otherwise I'd probably forget to change it occassionally when 
> > interacting with others than you).
> 
> For now either way is fine with me.  If the situation changes I'll
> let you know.

Ok, I'll remain in iso-8859-1, it's something that is known to work from 
my end. Thanks anyway for fixing it, wasn't any big deal for me at any 
point of time but people started asking me privately to correct it which 
I of course couldn't... :-)

> I'm surprised git-send-email can't get it purely utf8 correctly.

The problem is that my system is ISO natively, so git-send-email might 
encode a ISO native .patch file's content while sending, which in this 
case was intentionally already utf-8.

It might surprise you but it wasn't a long time ago when git-send-email 
wouldn't care less e.g. about header encoding and I got rejects from 
netdev due to my name which wasn't encoded properly, I've 1.5.0.6 
currently and it seemed still fail to encode Cc addresses it adds from 
signed-offs unless I explicitly ask for it to not do that (I explicitly 
ask for especific, encoded, from header anyway because it was broken at 
some point of time and my sending template is copy-paste originating
from that time). There was some recent fixes in the git's logs regarding 
that encoding, so I intend to check if a later g-s-e is more able and if 
it isn't I'll report it to git folks.

> I wonder if there is some issue with how it gets your name
> string for the commit author etc.

I've had it working well since the encoding header got relatively recently 
added (wasn't available at early dawn of git era), before that it was just 
a mess locally. Funny enough, you were able to magically mangle my emails 
to utf-8'ed commits nicely back then so I got a "fixed" commit back after 
an RTT :-).

> I wonder if getting it into your global GIT config file in proper
> UTF8 encoding would fix things.
>
> Put something like this into ~/.gitconfig
> 
> --------------------
> [user]
> 	name = Ilpo Järvinen
> 	email = ilpo.jarvinen@helsinki.fi
> --------------------

I have this. In addition I have this (required to make my local system 
consistent):

[i18n]
        commitencoding = ISO-8859-1

The problem was just that the API (or better, ABI) between us 
wasn't properly working :-)). While Herbert was working as the
replacement-Dave in November, correct commit entries were created,
so git has been working fine (I guess he used git applying tools
instead of handmade scripts and they handle email correclt based
on it's encoding).

I tried logOutputEncoding = utf-8 in the last patch sets I sent (now 
could again remove it) but git-send-email problem appeared with it
because the system is ISO natively.

> The GIT maintainer is Finnish which makes this situation even
> more perplexing to me, you might want to discuss it with him :-)

Junio? Never heard that a Finnish name... ;-) Perhaps
git-send-email wasn't written by that Finnish guy... :-) 
...Besides, that Finnish git aintainer doesn't have any funny
characters in his name... ;-)

Thanks anyway for the tips & all, I think we have it now working
and I can return to inlines and rexmit_skb_hint things & other TCP
stuff rather than this hinderance. I've some interesting results
from net header inlines checks I ran overnight :-).

-- 
 i.
---696243703-921463403-1200299614=:31652--
