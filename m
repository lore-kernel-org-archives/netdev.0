From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Wed, 4 Feb 2009 07:19:47 +0100
Message-ID: <20090204061947.GD20673@1wt.eu>
References: <20090203121209.GA9154@gondor.apana.org.au> <20090203121836.GA23300@ioremap.net> <20090203122535.GB8633@1wt.eu> <20090203.164734.76871204.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: zbr@ioremap.net, herbert@gondor.apana.org.au, jarkao2@gmail.com,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1994 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750892AbZBDGUW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2009 01:20:22 -0500
Content-Disposition: inline
In-Reply-To: <20090203.164734.76871204.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 03, 2009 at 04:47:34PM -0800, David Miller wrote:
> From: Willy Tarreau <w@1wt.eu>
> Date: Tue, 3 Feb 2009 13:25:35 +0100
> 
> > Well, FWIW, I've always observed better performance with 4k MTU (4080 to
> > be precise) than with 9K, and I think that the overhead of allocating 3
> > contiguous pages is a major reason for this.
> 
> With what hardware?  If it's with myri10ge, that driver uses page
> frags so would not be using 3 contiguous pages even for jumbo frames.

Yes myri10ge for the optimal 4080, but with e1000 too (though I don't
remember the exact optimal value, I think it was slightly lower).

For the myri10ge, could this be caused by the cache footprint then ?
I can also retry with various values between 4 and 9k, including
values close to 8k. Maybe the fact that 4k is better than 9 is
because we get better filling of all pages ?

I also remember having used a 7 kB MTU on e1000 and dl2k in the past.
BTW, 7k MTU on my NFS server which uses e1000 definitely stopped the
allocation failures which were polluting the logs, so it's been running
with that setting for years now.

Willy

