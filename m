From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [patch net-next 01/16] net: introduce upper device lists
Date: Tue, 14 Aug 2012 10:14:00 -0300
Message-ID: <20120814101400.0ef7aaa9@obelix.rh>
References: <1344871635-1052-1-git-send-email-jiri@resnulli.us>
	<1344871635-1052-2-git-send-email-jiri@resnulli.us>
	<20120813145217.38748c4f@obelix.rh>
	<20120814122433.GB1661@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	faisal.latif@intel.com, roland@kernel.org, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, fubar@us.ibm.com, andy@greyhouse.net,
	divy@chelsio.com, jitendra.kalsaria@qlogic.com,
	sony.chacko@qlogic.com, linux-driver@qlogic.com, kaber@trash.net,
	ursula.braun@de.ibm.com, blaschka@linux.vnet.ibm.com,
	linux390@de.ibm.com, shemminger@vyatta.com,
	bhutchings@solarflare.com, therbert@google.com,
	xiyou.wangcong@gmail.com, joe@perches.com,
	gregory.v.rose@intel.com, john.r.fastabend@intel.com,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-s390@vger.kernel.org, bridge@lists.linux-foundation.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63347 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755398Ab2HNNOh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2012 09:14:37 -0400
In-Reply-To: <20120814122433.GB1661@minipsycho.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 14 Aug 2012 14:24:33 +0200
Jiri Pirko <jiri@resnulli.us> wrote:

> Mon, Aug 13, 2012 at 07:52:17PM CEST, fbl@redhat.com wrote:
> >On Mon, 13 Aug 2012 17:27:00 +0200
> >Jiri Pirko <jiri@resnulli.us> wrote:
> >> +	/*
> >> +	 * To prevent loops, check if dev is not upper device to upper_dev.
> >> +	 */
> >> +	if (__netdev_has_upper_dev(upper_dev, dev, true))
> >> +		return -EBUSY;
> >> +
> >> +	if (__netdev_find_upper(dev, upper_dev))
> >> +		return -EEXIST;
> >
> >__netdev_has_upper_dev() can go all the way up finding the device and
> >the __netdev_find_upper() just check the first level.
> 
> 
> I do not think this ordering is somewhat inportant.

it's not the order, see below:

> >I think it would be better to use:
> >__netdev_find_upper_dev(,,deep=true/false)
> >__netdev_has_upper(,)

It's their names.  Currently, the function ..._find_... look at
one level only, while the function ..._has_... does one or more
levels.  I think it's better to swap 'has' and 'find' in their names:

__netdev_find_upper_dev(,,deep=true/false) <-- find in all levels
__netdev_has_upper(,)  <-- check only the one level.

fbl
