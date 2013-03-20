From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: How to assign sockaddr_nl->nl_groups when using connector
Date: Wed, 20 Mar 2013 22:29:20 +0400
Message-ID: <20130320182920.GA2837@ioremap.net>
References: <5147CA4F.5050801@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, KY Srinivasan <kys@microsoft.com>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>
To: vaughan <vaughan.cao@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host-176-100-244-43.masterbit.su ([176.100.244.43]:38701 "EHLO
	tservice.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755269Ab3CTS3Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Mar 2013 14:29:25 -0400
Content-Disposition: inline
In-Reply-To: <5147CA4F.5050801@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

On Tue, Mar 19, 2013 at 10:15:43AM +0800, vaughan (vaughan.cao@oracle.com) wrote:
> I am not quite sure how to assign nl_groups when using connector. You
> Documentation/connector/connector.txt don't explain it very clearly. I
> thought it's a bitmask representing only 32 groups.
> If I just want to subscribe only one group such as CN_KVP_IDX, what
> shall I do? Which one below is correct?
> a) l_local.nl_groups = CN_KVP_IDX;
> Or
> b) l_local.nl_groups = 1 << (CN_KVP_IDX -1)
> and bind with bind(s, (struct sockaddr *)&l_local, sizeof(struct
> sockaddr_nl)).

Iirc, first groups, created before bitmap-to-number conversion were
actually bitmaps, but then broadcast interface was obsoleted.

One should use NETLINK_ADD_MEMBERSHIP interface and specify gruop number
directly.

> I ran your example in Documentation/connector/. 'l_local.nl_groups = -1'
> in ucon.c seems subscribe all channels, because if I start cgred
> service, ucon will receive messages with idx=1.
> 
> And it seems setsockopt is not needed now, for it is done by
> netlink_autobind? You even comment it out using '#if 0' in
> Documentation/connector/ucon.c.
> 
> Could you do me a favor to check
> http://driverdev.linuxdriverproject.org/pipermail/devel/2013-March/036306.html
> to see if my understanding is correct or not? Thanks.

Yes, you are right.

-- 
	Evgeniy Polyakov
