From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: scp stalls mysteriously
Date: Fri, 4 Dec 2009 17:09:45 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0912041659450.19748@melkinpaasi.cs.helsinki.fi>
References: <4B16BD58.3040802@tvk.rwth-aachen.de> <20091203085933.GD30730@sd-11162.dedibox.fr> <alpine.DEB.2.00.0912031121190.7024@wel-95.cs.helsinki.fi> <4B17A791.80808@tvk.rwth-aachen.de> <alpine.DEB.2.00.0912031444150.7024@wel-95.cs.helsinki.fi>
 <4B17C6C3.1060000@tvk.rwth-aachen.de> <20091203202328.62d7551a@houba> <4B1820B8.7050500@tvk.rwth-aachen.de> <20091204093629.GA17976@sd-11162.dedibox.fr> <alpine.DEB.2.00.0912041302460.7024@wel-95.cs.helsinki.fi>
 <20091204135836.GB17976@sd-11162.dedibox.fr>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696230645-866132796-1259939385=:19748"
Cc: Damian Lukowski <damian@tvk.rwth-aachen.de>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: Frederic Leroy <fredo@starox.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:43228 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751615AbZLDPJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2009 10:09:39 -0500
In-Reply-To: <20091204135836.GB17976@sd-11162.dedibox.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696230645-866132796-1259939385=:19748
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Fri, 4 Dec 2009, Frederic Leroy wrote:

> On Fri, Dec 04, 2009 at 01:14:46PM +0200, Ilpo Järvinen wrote:
> > On Fri, 4 Dec 2009, Frederic Leroy wrote:
> > 
> > I noticed that we'll absolutely need that || !retrans_stamp thing as 
> > [...] 
> > But there may be other error handling related things here too. Can you try 
> > with the following once you can (probably can print quite much, once per 
> > arriving packet when in recovery):
> 
> I made 2 more trace .15 and .16 but ... 
> I applied your patch and forgot to add "|| !retrans_stamp" thing.
> 
> I can't test another kernel until this evening :(

I think it's fine without it too (I just meant that we'll need that || 
!retrans_stamp into mainline/stable for sure even if we find the cause for 
the another problem) and your traces now confirm what I was suspecting.
The retransmissions do not succeed because of error (-EAGAIN). Possibly 
from this check: 

        if (atomic_read(&sk->sk_wmem_alloc) >
            min(sk->sk_wmem_queued + (sk->sk_wmem_queued >> 2), sk->sk_sndbuf))
                return -EAGAIN;

...Or alternatively it comes from queue_xmit.

Eric, can you please take a look if you have a clue on this?


-- 
 i.
---696230645-866132796-1259939385=:19748--
