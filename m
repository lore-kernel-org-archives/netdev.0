From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 3/3] netlink: Lock out table resizes while dumping
 Netlink sockets
Date: Tue, 20 Jan 2015 15:00:58 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CACF400@AcuExch.aculab.com>
References: <cover.1421759056.git.tgraf@suug.ch>
 <e164edeacaeffee43be64d4ed6a5b5e7e8923bd1.1421759056.git.tgraf@suug.ch>
 <20150120143154.GR14883@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>,
	"ying.xue@windriver.com" <ying.xue@windriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
To: 'Patrick McHardy' <kaber@trash.net>, Thomas Graf <tgraf@suug.ch>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150120143154.GR14883@acer.localdomain>
Content-Language: en-US
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy
> On 20.01, Thomas Graf wrote:
> > Lock out table resizes while dumping Netlink sockets to user space.
> > This keeps disruptions to a minimum for readers which don't handle
> > the NLM_F_DUMP_INTR flag.
> 
> This doesn't lock them out for the duration of the entire dump of
> course, so the benefit seems rather small. Still with this patch,
> they will need to handle NLM_F_DUMP_INTR or will get unpredictable
> behaviour, in which case I'd think it makes more sense to not even
> try this, all it does is hide parts of the brokenness.
> 
> An alternative would be to set a flag in ht when a dump begins that
> indicates to skip resizing operations and on the end of the dump
> perform any resizing operations that might be necessary. Herbert
> disagrees though and he might be right.

Can you rely on being told when the dump completes?
If the program is killed in the middle then it can't tell you.

I suspect you'd have to suppress resize for some time interval
after a partial dump.
Unfortunately two continuous dumps would be likely to suppress
it forever. Maybe sleep user space dump requests for the first
block while any resize (esp. grow) is pending.

What is passed to userspace as the 'continue from here' marker?
Even without resize there are likely to be issues if something
nearer the head of a hash chain being processed is deleted.

	David

