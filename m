From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC NET 00/04]: Increase number of possible routing tables
Date: Fri, 07 Jul 2006 10:05:23 +0200
Message-ID: <44AE15C3.8050900@trash.net>
References: <20060703075259.6286.67397.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	greearb@candelatech.com, Thomas Graf <tgraf@suug.ch>,
	Robert.Olsson@data.slu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:24759 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932067AbWGGIFZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 04:05:25 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <20060703075259.6286.67397.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> I took on Ben's challenge to increase the number of possible routing tables,
> these are the resulting patches.
> 
> The table IDs are changed to 32 bit values and are contained in a new netlink
> routing attribute. For compatibility rtm_table in struct rtmsg can still be
> used to access the first 255 tables and contains the low 8 bit of the table
> ID in case of dumps. Unfortunately there are no invalid values for rtm_table,
> so the best userspace can do in case of a new iproute version that tries to
> access tables > 255 on an old kernel is to use RTM_UNSPEC (0) for rtm_table,
> which will make the kernel allocate an empty table instead of silently adding
> routes to a more or less random table. The iproute patch will follow shortly.
> 
> The hash tables are statically sized since on-the-fly resizing would require
> introducing locking in the packet processing path (currently we need none),
> if this is a problem we could just directly attach table references to rules,
> since tables are never deleted or freed this would be a simple change.
> 
> One spot is still missing (nl_fib_lookup), so these patches are purely a RFC
> for now. Tested only with IPv4, I mainly converted DECNET as well to keep it
> in sync and because iteration over all possible table values, as done in many
> spots, has an unacceptable overhead with 32 bit values.


Since there were no objections, I would like to finalize this patch by
takeing care of nl_fib_lookup. Since it was introduced as a debugging
interface for fib_trie and the interface definitions are not even
public (contained in include/net), I wonder if anyone really cares about
backwards compatibility or if I can just change it.

Robert, Thomas, you are the only two users of the interface I'm aware
of, what do you think?

