From: Andy Fleming <afleming@gmail.com>
Subject: Re: [PATCH] fsl_pq_mdio: Clean up tbi address configuration
Date: Thu, 1 Dec 2011 23:16:23 -0600
Message-ID: <CAKWjMd5+TqZpNPpbQhqf6V2dPVr05tvcHJdN9W3zM5Levn6GkA@mail.gmail.com>
References: <1321024239-18861-1-git-send-email-afleming@freescale.com>
	<20111114.002630.2254622894958283155.davem@davemloft.net>
	<D789ECCE-08DE-4E6D-BCA7-2C54EC5758B7@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, afleming@freescale.com,
	netdev@vger.kernel.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:47851 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750937Ab1LBFQY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 00:16:24 -0500
Received: by ghrr1 with SMTP id r1so2523708ghr.19
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2011 21:16:23 -0800 (PST)
In-Reply-To: <D789ECCE-08DE-4E6D-BCA7-2C54EC5758B7@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 1, 2011 at 10:38 PM, Kumar Gala <galak@kernel.crashing.org> wrote:
>
> On Nov 13, 2011, at 11:26 PM, David Miller wrote:
>
>> From: Andy Fleming <afleming@freescale.com>
>> Date: Fri, 11 Nov 2011 09:10:39 -0600
>>
>>> The code for setting the address of the internal TBI PHY was
>>> convoluted enough without a maze of ifdefs. Clean it up a bit
>>> so we allow the logic to fail down to -ENODEV at the end of
>>> the if/else ladder, rather than using ifdefs to repeat the same
>>> failure code over and over.
>>>
>>> Also, remove the support for the auto-configuration. I'm not aware of
>>> anyone using it, and it ends up using the bus mutex before it's been
>>> initialized.
>>>
>>> Signed-off-by: Andy Fleming <afleming@freescale.com>
>>
>> Applied, thanks.
>
> I believe we need this on mainline otherwise we get something like:

I concur. I also have a 2 separate patches I will send out tonight,
which are independent of each other, but related.

The first will revert c3e072f8a6c5625028531c40ec65f7e301531be2 (net:
fsl_pq_mdio: fix non tbi phy access), which hides a bug. The second
will fix the bug in our p1/p2 device trees so that they all have tbi
nodes.

The first patch only applies to net-next (reverts a commit in that
tree). The second patch only applies to Kumar's "next" branch (applies
changes on top of significant device-tree changes). I have no idea how
you guys want to deal with that. Personally, I think that the patches
can be applied to their respective trees, and anyone who is working
off the bleeding edge can go find the appropriate patch in the other
tree. If we get my first patch into mainline, then I imagine Kumar's
tree will have all the necessary components...

Anyway, I will leave that to you. I will submit the two patches in the
next hour or so.

Andy
