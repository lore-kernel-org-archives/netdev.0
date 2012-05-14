From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netfilter: xt_HMARK: endian bugs
Date: Mon, 14 May 2012 20:28:52 +0200
Message-ID: <1337020132.8512.598.camel@edumazet-glaptop>
References: <1337002943-16374-1-git-send-email-hans.schillstrom@ericsson.com>
	 <201205141809.18174.hans.schillstrom@ericsson.com>
	 <1337012674.8512.589.camel@edumazet-glaptop>
	 <201205141951.36692.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@inai.de>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"dan.carpenter@oracle.com" <dan.carpenter@oracle.com>,
	"hans@schillstrom.com" <hans@schillstrom.com>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <201205141951.36692.hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-05-14 at 19:51 +0200, Hans Schillstrom wrote:
> On Monday 14 May 2012 18:24:34 Eric Dumazet wrote:
> > On Mon, 2012-05-14 at 18:09 +0200, Hans Schillstrom wrote:
> > 
> > > This context can contain both le & be machines,
> > > so at least in hmark it make sense
> > 
> > Before jhash() and its shuffle ? What do you mean ?
> 
> I want that a Big endian machine should produce the same
> hash value independent of flow direction as a Little endian.
> 

So one machine can be both le and be ? at the same time ?

> OK, I missed ntohl() before calling jhash_3words()
> 
> Correct me if I'm wrong here (have no big endian machine available for test)
> jhash_3words() and __jhash_final() seems to be "endian" safe.
> 
> So by doing the expensive ntohl on addresses and ports into jhash_3words()
> it will produce the same value on both be and le.
> 

And what is the purpose of the jhash output ? Is is sent to other
machines on the network, or only localy used ?

> That's why I want to have the ntohs() / ntohl() when comparing.

If xt_HMARK depends on a particular bit ordering to jhash() input, then
something is really wrong. I mean it.

jhash() primary purpose it to shuffle input.

We use (__force u32) everywhere in network tree to avoid sparse
warnings. Please grep for them.



