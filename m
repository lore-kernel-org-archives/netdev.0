From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH] net: add a rate_limit attribute to netdev_queue and
 a rtnetlink
Date: Wed, 10 Jul 2013 20:10:02 -0700
Message-ID: <51DE220A.40505@intel.com>
References: <20130710140409.6691.77084.stgit@nitbit.x32> <CA+mtBx-Oa_Mb0YLu5W8sPcXqh80cD7rh5KvH0umzPv8YtbWEMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	ben@decadent.org.uk,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:26843 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755560Ab3GKDKZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jul 2013 23:10:25 -0400
In-Reply-To: <CA+mtBx-Oa_Mb0YLu5W8sPcXqh80cD7rh5KvH0umzPv8YtbWEMQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/10/2013 2:18 PM, Tom Herbert wrote:
> John, thanks for posting this.
>
> Should we have separate guaranteed and maximum rate?  Will this be
> usable in the case that more than one queue shares a rate?  Do you
> think other parameters, like priority weights should be done the same
> way?
>
> Tom
>

If hardware can provide a guaranteed min rate as well as a max rate
per queue then I think adding it here would be correct. Notice
guaranteed minimum rates and max rates can already be provided for a
set of queues (a traffic class or tc in the netdev struct) using the
DCB netlink interface.

So we have a hierarchy of attributes namely netdev->tc->queue.
It might be interesting to note a tc can consist of a single queue.
However hardware may not necessarily be able to rate limit a set of
queues or vice versa a single queue.

> Will this be usable in the case that more than one queue shares a rate?

Here I must not understand the question. Each queue has independent
rate limiters. At least in the hardware supported by ixgbe. Maybe
other hardware has a different implementation?

> Do you think other parameters, [...]

With regards to other attributes my intent was to create a structure
that we could easily add additional per queue attributes as needed.
So yes adding priority weights here makes some sense to me. Although
I wonder if priority weights overlaps the 'queue set' and 'tc' notion
already existing in the DCB netlink interface for configuring link
strict classes. With dcbnl and mqprio we can create upto 16 sets
of queues each with a priority mapping and the hardware will process
traffic in priority order. (ixgbe caveat: 82599 supports 8 sets of
queues X540 supports 4).

.John
