From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCHv3 net-next] ipv6: allow routes to be configured with
 expire values
Date: Thu, 17 Dec 2015 14:23:57 -0600
Message-ID: <1450383837.28806.4.camel@redhat.com>
References: <3b977653c7ade52e180d754eb660ec66af212e94.1450259411.git.lucien.xin@gmail.com>
	 <1450285432.23793.12.camel@redhat.com>
	 <20151217.150826.320110242014234511.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: lucien.xin@gmail.com, netdev@vger.kernel.org,
	hannes@stressinduktion.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60619 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932100AbbLQUX6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Dec 2015 15:23:58 -0500
In-Reply-To: <20151217.150826.320110242014234511.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-12-17 at 15:08 -0500, David Miller wrote:
> From: Dan Williams <dcbw@redhat.com>
> Date: Wed, 16 Dec 2015 11:03:52 -0600
> 
> > On Wed, 2015-12-16 at 17:50 +0800, Xin Long wrote:
> >> Add the support for adding expire value to routes,  requested by
> >> Tom Gundersen <teg@jklm.no> for systemd-networkd, and
> NetworkManager
> >> wants it too.
> >> 
> >> implement it by adding the new RTNETLINK attribute RTA_EXPIRES.
> > 
> > Could you also add bits to send RTA_EXPIRES back to userspace in
> the
> > route dump in rt6_fill_node(), so that userspace can figure out
> when
> > RTA_EXPIRES is supported or not?
> > 
> > (obviously having it there isn't foolproof as if there are no
> routes on
> > the system yet userspace can't figure out support, but it's better
> than
> > nothing...)
> 
> That brings up an interesting issue, and I do not agree that we
> should
> publish the value for the purpose of determining if the kernel
> supports
> it or not.

That said, userspace still needs to read back the EXPIRES attribute, if
only for iproute.  The program setting RTA_EXPIRES isn't the only thing
that wants to know about the route's details.

> We need to come up with a policy for handling unknown attributes
> because what we do now doesn't work.

Definitely agree.

> I'm almost positive that the right thing to do is to unilaterally
> making nlmsg_parse() error out on out-of-range attribute type
> numbers,
> and then backport that to all -stable branches.

This works for one attribute because then userspace gets an error like
EOPNOTSUPP or something.  But which attribute caused it?  Does
userspace then have to retry the operation a couple times with all the
different combinations of potentially unsupported options?

If we're going to error out on unrecognized options, I'd really like to
see some kind of netlink features bitmap or something that positively
indicates which options the kernel will accept.

Dan
