From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [fixed] [patch] Re: [bug] stuck localhost TCP connections,
 v2.6.26-rc3+
Date: Wed, 4 Jun 2008 09:42:58 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0806040927410.16057@wrl-59.cs.helsinki.fi>
References: <20080603094057.GA29480@elte.hu>  <Pine.LNX.4.64.0806032245490.3474@wrl-59.cs.helsinki.fi>
  <Pine.LNX.4.64.0806040052270.3474@wrl-59.cs.helsinki.fi>
 <20080603.150344.145518113.davem@davemloft.net>
 <Pine.LNX.4.64.0806040208350.7315@wrl-59.cs.helsinki.fi> <1212548093.12617.0.camel@tng>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-2131221771-1212560878=:16057"
Cc: David Miller <davem@davemloft.net>, mingo@elte.hu,
	peterz@infradead.org, LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, rjw@sisk.pl,
	Andrew Morton <akpm@linux-foundation.org>, johnpol@2ka.mipt.ru
To: Patrick McManus <mcmanus@ducksong.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33716 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751306AbYFDGnA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 02:43:00 -0400
In-Reply-To: <1212548093.12617.0.camel@tng>
Content-ID: <Pine.LNX.4.64.0806040928060.16057@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-2131221771-1212560878=:16057
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0806040928061.16057@wrl-59.cs.helsinki.fi>

On Tue, 3 Jun 2008, Patrick McManus wrote:

> On Wed, 2008-06-04 at 02:22 +0300, Ilpo Järvinen wrote:
> ==
> > --
> > [PATCH] tcp DEFER_ACCEPT: fix racy access to listen_sk
> > 
> > It seems that replacement of DA code also moved parts outside
> > of appropriate locking. The Ingo's problem seems to come from
> > the fact that two flows could now race in
> > (inet_csk_)reqsk_queue_add corrupting the queue. ...This can
> > leave dangling socks around which won't resolve themselves
> > without stimuli from outside (e.g., external RST would help
> > I think).

> do_rcv() clearly has the listening socket locked in the non-DA case, and
> in the DA case it is the 'child' ESTABLISHED socket that is locked -
> leaving the accept queue unprotected. So simple.

It also well explains why Ingo finally got the KERNEL: assertion 
(!sk->sk_ack_backlog) which is adjusted in the very same reqsk_queue_add 
making it and the actual queue come out of sync.

...too bad this has no relevance to Håkon's case, so more digging
is necessary... :-)

-- 
 i.
---696208474-2131221771-1212560878=:16057--
