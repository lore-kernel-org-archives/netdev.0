From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netfilter: xt_HMARK: endian bugs
Date: Mon, 14 May 2012 18:24:34 +0200
Message-ID: <1337012674.8512.589.camel@edumazet-glaptop>
References: <1337002943-16374-1-git-send-email-hans.schillstrom@ericsson.com>
	 <alpine.LNX.2.01.1205141702110.11548@frira.vanv.qr>
	 <1337009079.8512.535.camel@edumazet-glaptop>
	 <201205141809.18174.hans.schillstrom@ericsson.com>
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
In-Reply-To: <201205141809.18174.hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-05-14 at 18:09 +0200, Hans Schillstrom wrote:

> This context can contain both le & be machines,
> so at least in hmark it make sense

Before jhash() and its shuffle ? What do you mean ?

Please respin your patch using (__force u16/u32) instead of
useless/expensive ntohs() / ntohl() (in _this_ context of hashing)

If you compare two 32bits values, of course they must have same
ordering, but seeding jhash() is another matter.

(Granted all calls use the same ordering of course)

sparse is great tool, but if you add useless ntohl() calls to make
sparse silent, then its probably better to not use sparse.



