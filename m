From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] netfilter: finer grained nf_conn locking
Date: Mon, 6 Apr 2009 10:25:52 -0700
Message-ID: <20090406102552.391f7d96@nehalam>
References: <20090218051906.174295181@vyatta.com>
	<20090218052747.679540125@vyatta.com>
	<499BDB5D.2050105@trash.net>
	<499C1894.7060400@cosmosbay.com>
	<49CE568A.9090104@cosmosbay.com>
	<20090328174835.0d0b63f8@nehalam>
	<49D1241B.6020504@cosmosbay.com>
	<20090330130532.1e433313@nehalam>
	<49D9F086.7090905@trash.net>
	<alpine.LSU.2.00.0904061430160.1189@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44843 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751216AbZDFRZ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Apr 2009 13:25:59 -0400
In-Reply-To: <alpine.LSU.2.00.0904061430160.1189@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 6 Apr 2009 14:32:54 +0200 (CEST)
Jan Engelhardt <jengelh@medozas.de> wrote:

> 
> On Monday 2009-04-06 14:07, Patrick McHardy wrote:
> >>>
> >>> if LOCKDEP is on, size of a spinlock is 64 bytes on x86_64.
> >>> Adding a spinlock on each nf_conn would be too expensive. In this
> >>> case, an array of spinlock is a good compromise, as done in
> >>> IP route cache, tcp ehash, ...
> >>
> >> IMO having different locking based on lockdep and architecture is an
> >> invitation
> >> to future obscure problems. Perhaps some other locking method or shrinking
> >> ct entry would be better.
> >
> > I agree. Do people enable lockdep on production machines?
> 
> They do not.[1]
> 
> 
> [1] http://git.opensuse.org/?p=people/jblunck/kernel-source.git;a=blob;f=config/x86_64/default;hb=SL111_BRANCH

IMHO If they enable lockdep, they can expect that the cost is non-zero.
