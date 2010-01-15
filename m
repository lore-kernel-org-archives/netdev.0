From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [PATCH] Optimize TCP sendmsg in favour of fast devices?
Date: Fri, 15 Jan 2010 01:04:50 -0800 (PST)
Message-ID: <20100115.010450.64181969.davem@davemloft.net>
References: <20100115095049.14190a50@marrow.netinsight.se>
	<20100115.005224.257449393.davem@davemloft.net>
	<20100115100011.076505bf@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org, eric.dumazet@gmail.com
To: simon.kagstrom@netinsight.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43752
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751001Ab0AOJEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 04:04:42 -0500
In-Reply-To: <20100115100011.076505bf@marrow.netinsight.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Date: Fri, 15 Jan 2010 10:00:11 +0100

> On Fri, 15 Jan 2010 00:52:24 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
> 
>> > The same thing goes for via-velocity.c, it's turned on via ethtool
>> > though (ethtool_op_set_sg).
>> 
>> Indeed, see my reply to Krishna's ethtool_op_set_sg() patch.
>> 
>> I think it's a cruddy way to do things, SG ought to be on by
>> default always unless it is defective.  And if it's defective
>> support should be removed entirely.
> 
> I kept it off by default since I didn't see any big improvement in my
> tests (negative in some, positive in some). But I suppose you're
> right though.

Well, it has to provide significantly better performance for
sendfile() (especially wrt. cpu utilization) because we avoid the copy
out of the page cache pages entirely.
