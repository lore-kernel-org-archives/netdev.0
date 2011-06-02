From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] Use unsigned variables for packet lengths in ip[6]_queue.
Date: Thu, 2 Jun 2011 15:24:57 -0400
Message-ID: <20110602192457.GA19342@redhat.com>
References: <20110420014221.GC26949@redhat.com>
 <20110419.204105.68144653.davem@davemloft.net>
 <20110528003651.GA8380@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41104 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753880Ab1FBTZA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jun 2011 15:25:00 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p52JOx3T004098
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 2 Jun 2011 15:24:59 -0400
Received: from gelk.kernelslacker.org (ovpn-113-95.phx2.redhat.com [10.3.113.95])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id p52JOwak000327
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 2 Jun 2011 15:24:59 -0400
Received: from gelk.kernelslacker.org (gelk [127.0.0.1])
	by gelk.kernelslacker.org (8.14.5/8.14.4) with ESMTP id p52JOwC7019351
	for <netdev@vger.kernel.org>; Thu, 2 Jun 2011 15:24:58 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.5/8.14.5/Submit) id p52JOvgi019350
	for netdev@vger.kernel.org; Thu, 2 Jun 2011 15:24:57 -0400
Content-Disposition: inline
In-Reply-To: <20110528003651.GA8380@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 27, 2011 at 08:36:51PM -0400, Dave Jones wrote:

 >  > > Not catastrophic, but ipqueue seems to be too trusting of what it gets
 >  > > passed from userspace, and passes it on down to the page allocator,
 >  > > where it will spew warnings if the page order is too high.
 >  > > 
 >  > > __ipq_rcv_skb has several checks for lengths too small, but doesn't
 >  > > seem to have any for oversized ones.   I'm not sure what the maximum
 >  > > we should check for is. I'll code up a diff if anyone has any ideas
 >  > > on a sane maximum.
 >  > 
 >  > Maybe the thing to do is to simply pass __GFP_NOWARN to nlmsg_new()
 >  > in netlink_ack()?
 >  > 
 >  > Anyone else have a better idea?
 > 
 > So I went back to this today, and found something that doesn't look right.
 > After adding some instrumentation, and re-running my tests, I found that
 > the reason we were blowing up with enormous allocations was that we
 > were passing down a nlmsglen's like -1061109568
 > 
 > Is there any reason for that to be signed ?
 > The nlmsg_len entry of nlmsghdr is a u32, so I'm assuming this is a bug.
 > 
 > With the patch below, I haven't been able to reproduce the problem, but
 > I don't know if I've inadvertantly broken some other behaviour somewhere
 > deeper in netlink where this is valid.

any feedback on this ? am I barking up the wrong tree ?

	Dave

