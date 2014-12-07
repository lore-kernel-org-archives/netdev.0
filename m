From: "George Spelvin" <linux@horizon.com>
Subject: Re: Where exactly will arch_fast_hash be used
Date: 7 Dec 2014 08:30:56 -0500
Message-ID: <20141207133056.25209.qmail@ns.horizon.com>
References: <1417958080.17658.32.camel@localhost>
Cc: dborkman@redhat.com, herbert@gondor.apana.org.au,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org, tgraf@suug.ch
To: hannes@stressinduktion.org, linux@horizon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.horizon.com ([71.41.210.147]:44077 "HELO ns.horizon.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751487AbaLGNa5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Dec 2014 08:30:57 -0500
In-Reply-To: <1417958080.17658.32.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the encouragement!

> Please consider xfs, too.
> AFAIK xfs doesn't seed their hashing so far and the hashing function is
> pretty weak. One example:
> http://marc.info/?l=linux-xfs&m=139590613002926&w=2

Is that something that *can* be changed without breaking the
disk format?  SipHash is explicitly *not* designed to be secure as
an unkeyed hash in the way that SHA-type algorithms are.

What it's designed to do is provide second preimage resistance
of its output, or a function (like modular reduction) of its output,
against an attacker who doesn't know the secret seed.

> Ack. If we want to use it in the networking stack we should be able to
> use it without a dependency to the crypto framework.

Already understood.  My big question is whether a single function call
is okay or we need something inlinable.
