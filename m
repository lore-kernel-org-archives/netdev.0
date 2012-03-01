From: Rodrigo Moya <rodrigo.moya@collabora.co.uk>
Subject: Re: [PATCH 0/10] af_unix: add multicast and filtering features to
 AF_UNIX
Date: Thu, 01 Mar 2012 18:18:14 +0100
Message-ID: <1330622294.5373.8.camel@megeve>
References: <A1249B08688639468D1CB181445EE79D5A61B30431@ESESSCMS0355.eemea.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "netdev-owner@vger.kernel.org" <netdev-owner@vger.kernel.org>,
	"David.Laight@ACULAB.COM" <David.Laight@ACULAB.COM>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"javier@collabora.co.uk" <javier@collabora.co.uk>,
	"lennart@poettering.net" <lennart@poettering.net>,
	"kay.sievers@vrfy.org" <kay.sievers@vrfy.org>,
	"alban.crequy@collabora.co.uk" <alban.crequy@collabora.co.uk>,
	"bart.cerneels@collabora.co.uk" <bart.cerneels@collabora.co.uk>,
	"sjoerd.simons@collabora.co.uk" <sjoerd.simons@collabora.co.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: Erik Hugne <erik.hugne@ericsson.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <A1249B08688639468D1CB181445EE79D5A61B30431@ESESSCMS0355.eemea.ericsson.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Erik

On Thu, 2012-03-01 at 15:25 +0100, Erik Hugne wrote:
> Hi
> Have you considered using TIPC instead?
> It already provides multicast messaging with guaranteed ordering, and reliable delivery  (SOCK _RDM)
> 
I didn't know about TIPC, so have been having a quick look over it, and
have some questions about it:

* since it's for cluster use, I guess it's based on AF_INET sockets? if
so, see the messages from Luis Augusto and Javier about this breaking
current D-Bus apps, that use fd passing, for out-of-band data

* D-Bus works locally, with all processes on the same machine, but there
are 2 buses (daemons), one for system-related interfaces, and one per
user, so how would this work with TIPC. Can you create several
clusters/networks (as in TIPC addressing semantics) on the same machine
on the loopback device?

* I installed tipcutils on my machine, and it asked me if I wanted to
setup the machine as a TIPC node. Does this mean every machine needs to
be setup as a TIPC node before any app makes use of it? That is, can I
just create a AF_TIPC socket on this machine and just make it work
without any further setup?

* I guess it is easy to prevent any TIPC-enabled machine to get into the
local communication channel, right? That is, what's the security
mechanism for allowing local-only communications?

I'll stop asking questions and have a deeper look at it :)
