From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [RFC PATCH] Change "local" route table preference from 0 to 3fff, to permit send-to-self policy routing
Date: Sat, 19 Jun 2004 00:45:29 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040618204529.GA3106@ms2.inr.ac.ru>
References: <20040618182505.195d76ba.random@72616e646f6d20323030342d30342d31360a.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mark Smith <random@72616e646f6d20323030342d30342d31360a.nosense.org>
Content-Disposition: inline
In-Reply-To: <20040618182505.195d76ba.random@72616e646f6d20323030342d30342d31360a.nosense.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> that problem. Something I'll look into further, unless somebody can tell me
> that having a host reply its own ARP requests, even when received over a real
> interface, isn't possible at all.

Sigh, do not you think that making undelatable local rule with preference 0 was
an easy decision. This kills most of coolness of policy making yet. :-)

Essentially, your patch becomes 100% legal after we kill the places
where we ask "Is X.X.X.X our local address?". This thing with arp is one
of many places when we have to do this to keep stack relatively coherent.
We have several places where we do lookup directly in local table bypassing
policy rules, because we just do not have enough information to look
in right place.

> kernel hacking, if there is a better way to change the "local" route table
> preference, I'm all ears.

No, really. It is the best. Not made only as fool proof, because adding
almost any rule before local one shuts down networking completely.

Alexey
