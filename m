From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] bonding: fix panic if initialization fails
Date: Sat, 9 May 2009 01:30:57 +0200
Message-ID: <20090508233057.GQ3035@Chamillionaire.breakpoint.cc>
References: <1241819351-26356-1-git-send-email-fw@strlen.de> <20090508232100.GB4881@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:54521 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755829AbZEHXbD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2009 19:31:03 -0400
Content-Disposition: inline
In-Reply-To: <20090508232100.GB4881@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jpirko@redhat.com> wrote:
> > err:
> >-	list_for_each_entry(bond, &bond_dev_list, bond_list) {
> >-		bond_work_cancel_all(bond);
> >-		destroy_workqueue(bond->wq);
> >-	}
> This looks correct.
> 
> >-
> >-	bond_destroy_sysfs();
> Why this is not here anymore? I think it should be called in this function.

Thanks for reviewing.
I removed it because, if you hit this error path, sysfs registration
failed, so there is no entry to remove.

Its not a bug to call it though
(sysfs_hash_and_remove() returns -ENOENT in that case), and i can
re-spin without that change if you want.
