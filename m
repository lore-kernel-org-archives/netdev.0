From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/6] cxgb4: Add main driver file and driver Makefile
Date: Wed, 31 Mar 2010 19:18:44 -0700 (PDT)
Message-ID: <20100331.191844.186998605.davem@davemloft.net>
References: <4BB3E689.4050001@chelsio.com>
	<20100331.172401.00333850.davem@davemloft.net>
	<4BB3F827.3010402@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: dm@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47703
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751629Ab0DACSn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 22:18:43 -0400
In-Reply-To: <4BB3F827.3010402@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dimitris Michailidis <dm@chelsio.com>
Date: Wed, 31 Mar 2010 18:34:31 -0700

> David Miller wrote:
> 
>>> So, I propose getting rid of 3-4 of these files that are of lesser
>>> value and moving the rest to debugfs for now.  If some alternative
>>> through ethtool or something becomes available I can get rid of
>>> anything that can be handled through a more general facility.  Would
>>> that be acceptable?
>> You can use sysfs.
> 
> sysfs is a possibility but I thought Stephen's initial concern was
> that I was adding too many of these proc files and that they were
> creating a potential API.

Yes, since procfs is essentially deprecated these days.

> sysfs will result in a lot more files with its value-per-file model
> and I think sysfs and proc are similar in "APIness". So it's not
> clear to me how going to sysfs would address Stephen's point. The
> remove-a-few plus move-to-debugfs proposal was in order to end up
> with fewer files in a non-API filesystem.

It's in fact easier to retain API by using sysfs.  Instead of having
to worry about the format of a procfs file listing entries one by one
per line, under sysfs you just add a new file to export new values.

> As these builtin switches become more common I expect an official way
> to represent and access them will emerge but maybe it's not a good
> idea to introduce a sysfs model for them as part of this driver
> submission.

What nodes you create under your own device object in sysfs is your
domain and your business.  Since it's one value per file there is no
real complexity in making sure tools can display the values properly.
