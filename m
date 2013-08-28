From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next v1 5/9] bonding: convert bond_has_this_ip() to
 use upper devices
Date: Wed, 28 Aug 2013 18:32:46 +0200
Message-ID: <20130828163246.GL1992@redhat.com>
References: <1377549162-7522-1-git-send-email-vfalico@redhat.com>
 <1377549162-7522-6-git-send-email-vfalico@redhat.com>
 <20130826205338.GA3723@minipsycho.orion>
 <20130827111648.GB24836@redhat.com>
 <20130827112529.GA4732@minipsycho.brq.redhat.com>
 <20130827181001.GD24836@redhat.com>
 <521E0FA0.5070506@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22538 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752524Ab3H1Qew (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 12:34:52 -0400
Content-Disposition: inline
In-Reply-To: <521E0FA0.5070506@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 28, 2013 at 10:56:32AM -0400, Vlad Yasevich wrote:
...snip...
>I've been playing with approach 2 for some work I am doing for
>macvtap-over-bond, but I like you idea for 3 better.
>
>It would make things simpler in the long run.

I've just sent the third version of the 3rd approach, which implements
lower/upper device lists for every device that are guaranteed, under RCU,
tu have all the upper/lower devices linked to the device. It also permits
to distinguish the 'neighbour' devices (i.e. linked on the first level,
i.e. direct-linked) from the 'distant' ones, which are not directly linked
but rather inherited.

It also implements the first function (and the only one that I've needed
to get rid of vlan lists in bonding) - netdev_for_each_upper_dev_rcu(),
which can be used as a loop:

struct net_device *upper;
struct list_head *iter;

rcu_read_lock();
netdev_for_each_upper_dev_rcu(dev, upper, iter) {
	... do whatever you want with the upper dev ...
}
rcu_read_unlock();


In case you'll need, you can easily implement the same way
netdev_for_each_lower_dev_rcu().

Hope that helps.

>
>-vlad
