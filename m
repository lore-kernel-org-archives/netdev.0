From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Wed, 4 Feb 2009 11:12:01 +0300
Message-ID: <20090204081201.GB10445@ioremap.net>
References: <20090203121209.GA9154@gondor.apana.org.au> <20090203121836.GA23300@ioremap.net> <20090203122535.GB8633@1wt.eu> <20090203.164734.76871204.davem@davemloft.net> <20090204061947.GD20673@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	jarkao2@gmail.com, dada1@cosmosbay.com, ben@zeus.com,
	mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: Willy Tarreau <w@1wt.eu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754366AbZBDIM0@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090204061947.GD20673@1wt.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 04, 2009 at 07:19:47AM +0100, Willy Tarreau (w@1wt.eu) wrote:
> Yes myri10ge for the optimal 4080, but with e1000 too (though I don't
> remember the exact optimal value, I think it was slightly lower).

Very likely it is related to the allocator - the same allocation
overhead to get a page, but 2.5 times bigger frame.

> For the myri10ge, could this be caused by the cache footprint then ?
> I can also retry with various values between 4 and 9k, including
> values close to 8k. Maybe the fact that 4k is better than 9 is
> because we get better filling of all pages ?
> 
> I also remember having used a 7 kB MTU on e1000 and dl2k in the past.
> BTW, 7k MTU on my NFS server which uses e1000 definitely stopped the
> allocation failures which were polluting the logs, so it's been running
> with that setting for years now.

Recent e1000 (e1000e) uses fragments, so it does not suffer from the
high-order allocation failures.

-- 
	Evgeniy Polyakov
