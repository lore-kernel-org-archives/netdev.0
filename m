From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] flowi: add concept of "not_oif"
Date: Wed, 3 Feb 2016 22:42:51 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1602032149170.1802@ja.home.ssi.bg>
References: <CAHmME9pgwgjKJAFH2=sEEMJauno_rVEzY6JORTQze91Xo5zefw@mail.gmail.com> <1454521595-6721-1-git-send-email-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	dsa@cumulusnetworks.com
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:45032 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932088AbcBCUnB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Feb 2016 15:43:01 -0500
In-Reply-To: <1454521595-6721-1-git-send-email-Jason@zx2c4.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 3 Feb 2016, Jason A. Donenfeld wrote:

> This patch simply adds support for specifying a "not_oif" device in
> flowi4 and flowi6 lookups, that will find a matching route that _isn't_
> via the specified device.

	If you check every flowi4_oif user you will notice
that some places can not fulfil this requirement:

- fib_select_path -> fib_select_multipath

	Other places like fib_select_default are called
for flowi4_oif=0 and there are no other checks for flowi4_oif
but they will be needed for the new field.

	I don't know about the particular problems with
tunnels but the scripts can use the route metric to order
the routes in a table. Your patch looks simple but misses
a dozen of problems. The first breakage should be from the
missing initialization of this new field because the flowi
structure is not initialized at some places. Random
stack can lead to skipped routes. If this feature has
fans, you have to check all places that use flowi4_oif and
flowi6_oif.

Regards
