From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [RFC PATCH 04/13] xen-netback: implement RX persistent grants
Date: Tue, 2 Jun 2015 16:07:04 +0100
Message-ID: <20150602150704.GQ19403@zion.uk.xensource.com>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
 <1431451117-70051-5-git-send-email-joao.martins@neclab.eu>
 <20150519153205.GC26335@zion.uk.xensource.com>
 <65A385A5-4D11-4032-BB1B-82180AF76477@neclab.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ian.campbell@citrix.com" <ian.campbell@citrix.com>,
	"david.vrabel@citrix.com" <david.vrabel@citrix.com>,
	"boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Joao Martins <Joao.Martins@neclab.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:58647 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759046AbbFBPJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 11:09:24 -0400
Content-Disposition: inline
In-Reply-To: <65A385A5-4D11-4032-BB1B-82180AF76477@neclab.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 22, 2015 at 10:25:10AM +0000, Joao Martins wrote:
> 
> On 19 May 2015, at 17:32, Wei Liu <wei.liu2@citrix.com> wrote:
> 
> > On Tue, May 12, 2015 at 07:18:28PM +0200, Joao Martins wrote:
> >> It starts by doing a lookup in the tree for a gref. If no persistent
> >> grant is found on the tree, it will do grant copy and prepare
> >> the grant maps. Finally valides the grant map and adds it to the tree.
> > 
> > validates?
> > 
> >> After mapped these grants can be pulled from the tree in the subsequent
> >> requests. If it's out of pages in the tree pool, it will fallback to
> >> grant copy.
> >> 
> > 
> > Again, this looks complicated. Why use combined scheme? I will do
> > detailed reviews after we're sure we need such scheme.
> When we don't have the gref in tree we need to map it and then copying
> afterwards into the newly mapped page (and this only happens once until
> the grant is in tree). My options here were to either do this explicitly,
> after we add the persistent grant in which we would need to save to
> dst/src address and len to copy. The other option is to reuse the grant
> copy (since it's only once until the grant is in the tree) and use memcpy
> in followings requests. Additionally I allow the fallback to grant copy in

Which approach were you using here? I looked at the code but couldn't
quite get which one you were getting at. I guess the first one?

> case the guest provides providing more grefs > max_grants.
> 
> Note that this is also the case for TX as well, with regard to grant
> copying the header. I was unsure about which one is the most correct way
> of doing it, but ultimately the latter involved a smaller codepath, and
> that's why I chose it. What do you think?
> 

Shorter is better. Easier to understand.

Wei.
