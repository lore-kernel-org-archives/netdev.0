From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 3/3] netlink: Lock out table resizes while dumping
 Netlink sockets
Date: Tue, 20 Jan 2015 15:05:46 +0000
Message-ID: <20150120150546.GI20315@casper.infradead.org>
References: <cover.1421759056.git.tgraf@suug.ch>
 <e164edeacaeffee43be64d4ed6a5b5e7e8923bd1.1421759056.git.tgraf@suug.ch>
 <20150120143154.GR14883@acer.localdomain>
 <063D6719AE5E284EB5DD2968C1650D6D1CACF400@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Patrick McHardy' <kaber@trash.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>,
	"ying.xue@windriver.com" <ying.xue@windriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CACF400@AcuExch.aculab.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/20/15 at 03:00pm, David Laight wrote:
> From: Patrick McHardy
> > An alternative would be to set a flag in ht when a dump begins that
> > indicates to skip resizing operations and on the end of the dump
> > perform any resizing operations that might be necessary. Herbert
> > disagrees though and he might be right.
> 
> Can you rely on being told when the dump completes?
> If the program is killed in the middle then it can't tell you.
> 
> I suspect you'd have to suppress resize for some time interval
> after a partial dump.
> Unfortunately two continuous dumps would be likely to suppress
> it forever. Maybe sleep user space dump requests for the first
> block while any resize (esp. grow) is pending.
> 
> What is passed to userspace as the 'continue from here' marker?
> Even without resize there are likely to be issues if something
> nearer the head of a hash chain being processed is deleted.

I assumed that the proposal would include a timer in the Netlink
cb which fires after 2s or so and cancels the dump. 2s is still
a long time and a lot of inserts can happen in the meantime.

This may become more viable once insert()s can fail above a
certain watermark as Herbert suggests.
