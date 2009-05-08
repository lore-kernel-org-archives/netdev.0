From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] bonding: fix panic if initialization fails
Date: Sat, 9 May 2009 01:36:04 +0200
Message-ID: <20090508233604.GD4881@psychotron.englab.brq.redhat.com>
References: <1241819351-26356-1-git-send-email-fw@strlen.de> <20090508232100.GB4881@psychotron.englab.brq.redhat.com> <20090508233057.GQ3035@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:34961 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755626AbZEHXgM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 May 2009 19:36:12 -0400
Content-Disposition: inline
In-Reply-To: <20090508233057.GQ3035@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, May 09, 2009 at 01:30:57AM CEST, fw@strlen.de wrote:
>Jiri Pirko <jpirko@redhat.com> wrote:
>> > err:
>> >-	list_for_each_entry(bond, &bond_dev_list, bond_list) {
>> >-		bond_work_cancel_all(bond);
>> >-		destroy_workqueue(bond->wq);
>> >-	}
>> This looks correct.
>> 
>> >-
>> >-	bond_destroy_sysfs();
>> Why this is not here anymore? I think it should be called in this function.
>
>Thanks for reviewing.
>I removed it because, if you hit this error path, sysfs registration
>failed, so there is no entry to remove.

Yes, you are rigth.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

>
>Its not a bug to call it though
>(sysfs_hash_and_remove() returns -ENOENT in that case), and i can
>re-spin without that change if you want.
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
