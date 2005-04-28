From: Thomas Graf <tgraf@suug.ch>
Subject: Re: patch: policy update by id
Date: Thu, 28 Apr 2005 14:33:10 +0200
Message-ID: <20050428123310.GY577@postel.suug.ch>
References: <20050428012135.GA22950@gondor.apana.org.au> <20050428013014.GA23043@gondor.apana.org.au> <1114653140.7663.36.camel@localhost.localdomain> <20050428020754.GA23326@gondor.apana.org.au> <20050427194356.58a3e618.davem@davemloft.net> <20050428025644.GA23823@gondor.apana.org.au> <1114658160.7663.102.camel@localhost.localdomain> <20050428032045.GA24041@gondor.apana.org.au> <20050428114308.GX577@postel.suug.ch> <4270D286.7060301@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, jamal <hadi@cyberus.ca>,
        "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <4270D286.7060301@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Patrick McHardy <4270D286.7060301@trash.net> 2005-04-28 14:09
> Thomas Graf wrote:
> >* Herbert Xu <20050428032045.GA24041@gondor.apana.org.au> 2005-04-28 13:20
> >
> >>iptables -D INPUT 2
> >
> >Except for when another iptables instance has modified the ordering of
> >the rules by inserting or deleting a rule in the meantime. Please do
> >not adopt this scheme, it's completely unreliable.
> 
> Yes, if you don't know the ordering of your ruleset it is unreliable :)

Even if you know the ordering, the knowledge may expire very fast. It's
getting more and more common to automate the insertion and deletion of
rules via scripts triggered by events. I'm more or less fine with this
choice but it's nowhere near an index but rather just a line based
offset. I've seen user interfaces relying on -D, guess what happens if
more than one person uses the interface. It wouldn't cost much to
introduce a 64bit generated identifier and return that it userspace
but it would give higher level applications a chance to reidentify
rules, safely delete a certain rule, and would probably speed up the
deletion of a single rule out of a rather big ruleset considerably.
