From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6.24][patch 2/2] Dynamically allocate the loopback
 device
Date: Tue, 25 Sep 2007 19:24:06 -0700 (PDT)
Message-ID: <20070925.192406.18290033.davem@davemloft.net>
References: <224b7d320709171212o66734847kbd17efa817b482fc@mail.gmail.com>
	<20070917.185349.98863851.davem@davemloft.net>
	<m1r6kwpu9t.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pjwaskiewicz@gmail.com, dlezcano@fr.ibm.com,
	shemminger@linux-foundation.org, netdev@vger.kernel.org,
	containers@lists.osdl.org, benjamin.thery@bull.net
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41747
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752865AbXIZCYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2007 22:24:06 -0400
In-Reply-To: <m1r6kwpu9t.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 17 Sep 2007 20:44:14 -0600

> David Miller <davem@davemloft.net> writes:
> 
> > From: "Peter Waskiewicz" <pjwaskiewicz@gmail.com>
> > Date: Mon, 17 Sep 2007 12:12:24 -0700
> >
> >> This would be a good opportunity to remove the single-allocated queue struct
> >> in netdevice (at the bottom) that we had to put in to accomodate the static
> >> loopback.  Now we can set it back to a zero element list, and have
> >> alloc_netdev_mq() just allocate the number of queues requested, not
> >> num_queues - 1.
> >> 
> >> I'll put a patch together based on this patchset.
> >
> > Thanks Peter.
> >
> > I'll also let this sit so that Eric can provide any feedback
> > he wants and also figure out how he will use this for the
> > namespace stuff.
> 
> Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>
> Not that it doesn't already have my signed off by.

I've put these patches into the just-rebased net-2.6.24 tree.

I made a minor modification to the second patch, the
out_free_netdev: code in loopback_init() ended like this:

out_free_netdev:
	free_netdev(dev);
	goto out;
	return err;
};

I got rid of the spurious return statement and the trailing
semi-colon after the function closing brace.

Thanks.

