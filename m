From: Jean Sacren <sakiwit@gmail.com>
Subject: Re: [PATCH net-next 3/3] net: core: fix wrong linkage for ptype_base
 and ptype_all symbols
Date: Tue, 6 Aug 2013 14:45:08 -0600
Message-ID: <20130806204508.GA2274@mail.gmail.com>
References: <1375774371-831-1-git-send-email-sakiwit@gmail.com>
 <1375774371-831-3-git-send-email-sakiwit@gmail.com>
 <5200B01B.9080705@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:63414 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754269Ab3HFUrQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 16:47:16 -0400
Received: by mail-pb0-f53.google.com with SMTP id up15so960268pbc.26
        for <netdev@vger.kernel.org>; Tue, 06 Aug 2013 13:47:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5200B01B.9080705@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue, 06 Aug 2013 10:13:15 +0200
>
> On 08/06/2013 09:32 AM, Jean Sacren wrote:
> > In commit 900ff8c6 ("net: move procfs code to net/core/net-procfs.c"),
> > it changed the correct linkage of ptype_base and ptype_all symbols to
> > the wrong one in net/core/dev.c, yet failed to change to the correct
> > linkage of those two in net/core/net-procfs.c.
> >
> > Fix the wrong linkage by setting static specifier to both sets of the
> > symbols so that they could have coherent internal linkage by themselves
> > to avoid interference with each other.
> 
> Ho? I do not think this is correct, what makes you think so?

Thank you for the awesome comment.

I'm sorry to tell you but the patch is correct. Both symbols of
ptype_{base,all} were wrongly declared as extern in net-procfs.c in the
first place.

> The net-procfs.c usage of ptype_* is there to show current pf_packet users
> via seq_files in procfs. Your patch will just break this.

I validated it before I submitted the patch that all the symbols of
ptype_{base,all} are used exclusively in net/core/net-procfs.c and
net/core/dev.c but not outside of those two places. Therefore, your
assumption for breakage is groundless.

As a kernel networking guru as you are, you shall have the lab and all
sorts of test cases to validate patches. I'd love to run this type of
testing by myself, but I don't have such resources. If you could test
this patch in any of your setup and prove that I'm wrong, I'd extremely
appreciate it. Thank you in advance.

I'm looking forward to being taught more.

-- 
Jean Sacren
