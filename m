From: Paul Moore <paul@paul-moore.com>
Subject: Re: [patch] cipso: remove an unneeded NULL check in cipso_v4_doi_add()
Date: Wed, 12 Oct 2011 17:28:08 -0400
Message-ID: <1993964.1HBym86W0O@sifl>
References: <20111011132228.GA27127@elgon.mountain> <CAHC9VhRMy-DbbkXSSWQPh8QgHAm5xzZ1qWJaYLiOERPagDfrbQ@mail.gmail.com> <20111011215549.GC30887@longonot.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:52956 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752246Ab1JLV2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2011 17:28:16 -0400
In-Reply-To: <20111011215549.GC30887@longonot.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, October 12, 2011 12:55:49 AM Dan Carpenter wrote:
> On Tue, Oct 11, 2011 at 05:20:11PM -0400, Paul Moore wrote:
> > > -       if (doi_def == NULL || doi_def->doi == CIPSO_V4_DOI_UNKNOWN)
> > > +       if (doi_def->doi == CIPSO_V4_DOI_UNKNOWN)
> > >                goto doi_add_return;
> > >        for (iter = 0; iter < CIPSO_V4_TAG_MAXCNT; iter++) {
> > >                switch (doi_def->tags[iter]) {
> > 
> > I'd prefer to keep the NULL check in there as it does afford a little
> > bit of extra safety and this is management code after all, not
> > per-packet processing code, so the extra check should have no
> > observable performance impact.
> 
> The dereferences on the lines before mean we would Oops before
> reaching the check ...

Thanks for pointing that out, I missed that when looking at your patch.

-- 
paul moore
www.paul-moore.com
