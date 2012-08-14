From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 01/16] net: introduce upper device lists
Date: Tue, 14 Aug 2012 15:35:35 +0200
Message-ID: <20120814133535.GC1661@minipsycho.brq.redhat.com>
References: <1344871635-1052-1-git-send-email-jiri@resnulli.us>
 <1344871635-1052-2-git-send-email-jiri@resnulli.us>
 <20120813145217.38748c4f@obelix.rh>
 <20120814122433.GB1661@minipsycho.brq.redhat.com>
 <20120814101400.0ef7aaa9@obelix.rh>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: Flavio Leitner <fbl@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120814101400.0ef7aaa9@obelix.rh>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tue, Aug 14, 2012 at 03:14:00PM CEST, fbl@redhat.com wrote:
>On Tue, 14 Aug 2012 14:24:33 +0200
>Jiri Pirko <jiri@resnulli.us> wrote:
>
>> Mon, Aug 13, 2012 at 07:52:17PM CEST, fbl@redhat.com wrote:
>> >On Mon, 13 Aug 2012 17:27:00 +0200
>> >Jiri Pirko <jiri@resnulli.us> wrote:
>> >> +	/*
>> >> +	 * To prevent loops, check if dev is not upper device to upper_dev.
>> >> +	 */
>> >> +	if (__netdev_has_upper_dev(upper_dev, dev, true))
>> >> +		return -EBUSY;
>> >> +
>> >> +	if (__netdev_find_upper(dev, upper_dev))
>> >> +		return -EEXIST;
>> >
>> >__netdev_has_upper_dev() can go all the way up finding the device and
>> >the __netdev_find_upper() just check the first level.
>> 
>> 
>> I do not think this ordering is somewhat inportant.
>
>it's not the order, see below:
>
>> >I think it would be better to use:
>> >__netdev_find_upper_dev(,,deep=true/false)
>> >__netdev_has_upper(,)
>
>It's their names.  Currently, the function ..._find_... look at
>one level only, while the function ..._has_... does one or more
>levels.  I think it's better to swap 'has' and 'find' in their names:
>
>__netdev_find_upper_dev(,,deep=true/false) <-- find in all levels
>__netdev_has_upper(,)  <-- check only the one level.

Oh, now I think I see your point. But realise this:

The main reason for __netdev_find_upper() is to find "struct upper" for
netdev_upper_dev_unlink(). Therefore the name is not
"__netdev_find_upper_dev" and there's no need to go deep here.

On the orher hand, __netdev_has_upper_dev() only says whether device is lower
to specified upper device. In this case I think the name is quite
convenient as well.


>
>fbl
