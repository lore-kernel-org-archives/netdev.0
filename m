From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [RFC][PATCH] Fixing SA/SP dumps on netlink/af_key
Date: Fri, 18 Jan 2008 08:45:39 +0200
Message-ID: <47904B13.9060409@iki.fi>
References: <E1JFHDM-00010A-00@gondolin.me.apana.org.au> <1200533980.4451.100.camel@localhost> <20080117021743.GA5182@gondor.apana.org.au> <478EED98.6080603@iki.fi> <1200573750.4508.29.camel@localhost> <20080117125016.GA9820@gondor.apana.org.au> <478F58A2.6030209@iki.fi> <20080117213448.GA14716@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jamal <hadi@cyberus.ca>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:41999 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753109AbYARGoX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 01:44:23 -0500
Received: by fg-out-1718.google.com with SMTP id e21so932827fga.17
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 22:44:22 -0800 (PST)
In-Reply-To: <20080117213448.GA14716@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Thu, Jan 17, 2008 at 03:31:14PM +0200, Timo Ter=E4s wrote:
>> I guess the idea was that application should know about the SAs it
>> created. Though a SA dump needs to be done if you want to check
>> for existing entries (created by other processes, or if you are
>> recovering from a crash).
>=20
> That's what SADB_GET is for.  In any case KMs cannot coexist so this
> is pointless.  After a crash you should simply flush all states and
> policies.

I thought KMs could coexist. Actually, in strongSwan you have two
daemons: charon and pluto. Both can run at the same time. The other
is for IKEv1 and the other one for IKEv2. It uses netlink, though.
Looking the way pfkey works, it looks like being designed to work
with multiple KMs (e.g. acquires are sent to all registered sockets).

>> SPD dumping is still a must if you want to work nicely with kernel.
>=20
> No it isn't.  Look at how Openswan does it.  No dumping anywhere at a=
ll.

Then you have to have all policy/static association configuration in
the application configuration. ipsec-tools wanted separate that. As
this is more robust if someone decided to run multiple KMs.

My point (as an ipsec-tools developer) is that the patch would fix
a lot of problems until ipsec-tools is netlink enabled. It would
handle perfectly the dumping even as non-atomic. And that ipsec-tools
is the KM you get by default in almost all distributions.

But apparently you are too worried that all the so many other KMs
still using pfkey (is there others? I think most others use netlink
already) in Linux might break because the rely on an unspecified
feature of pfkey.

I'm also tired of arguing since this is going nowhere. I'll run my
patched kernel and try to get ipsec-tools fixed to use netlink...
eventually.

