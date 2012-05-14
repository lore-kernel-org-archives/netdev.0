From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [PATCH] netfilter: xt_HMARK: endian bugs
Date: Mon, 14 May 2012 19:51:34 +0200
Message-ID: <201205141951.36692.hans.schillstrom@ericsson.com>
References: <1337002943-16374-1-git-send-email-hans.schillstrom@ericsson.com> <201205141809.18174.hans.schillstrom@ericsson.com> <1337012674.8512.589.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@inai.de>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"dan.carpenter@oracle.com" <dan.carpenter@oracle.com>,
	"hans@schillstrom.com" <hans@schillstrom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1337012674.8512.589.camel@edumazet-glaptop>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 14 May 2012 18:24:34 Eric Dumazet wrote:
> On Mon, 2012-05-14 at 18:09 +0200, Hans Schillstrom wrote:
> 
> > This context can contain both le & be machines,
> > so at least in hmark it make sense
> 
> Before jhash() and its shuffle ? What do you mean ?

I want that a Big endian machine should produce the same
hash value independent of flow direction as a Little endian.

OK, I missed ntohl() before calling jhash_3words()

Correct me if I'm wrong here (have no big endian machine available for test)
jhash_3words() and __jhash_final() seems to be "endian" safe.

So by doing the expensive ntohl on addresses and ports into jhash_3words()
it will produce the same value on both be and le.

That's why I want to have the ntohs() / ntohl() when comparing.

> 
> Please respin your patch using (__force u16/u32) instead of
> useless/expensive ntohs() / ntohl() (in _this_ context of hashing)
> 
> If you compare two 32bits values, of course they must have same
> ordering, but seeding jhash() is another matter.
> 
> (Granted all calls use the same ordering of course)
> 
> sparse is great tool, but if you add useless ntohl() calls to make
> sparse silent, then its probably better to not use sparse.
> 
