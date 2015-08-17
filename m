From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH] net: rtnetlink: be more strict when setting MAC address
Date: Tue, 18 Aug 2015 01:23:16 +0200
Message-ID: <20150817232316.GA20744@orbit.nwl.cc>
References: <1439845607-2824-1-git-send-email-phil@nwl.cc>
 <20150817.140933.1342685440755543932.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, tgraf@suug.ch,
	Stephen Hemminger <shemming@brocade.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:37350 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751336AbbHQXXS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Aug 2015 19:23:18 -0400
Content-Disposition: inline
In-Reply-To: <20150817.140933.1342685440755543932.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 17, 2015 at 02:09:33PM -0700, David Miller wrote:
> From: Phil Sutter <phil@nwl.cc>
> Date: Mon, 17 Aug 2015 23:06:47 +0200
> 
> > Upon evaluation of IFLA_ADDRESS and IFLA_BROADCAST messages, make sure
> > the passed argument length matches dev->addr_len exactly.
> > 
> > This fixes dubious behaviour of 'ip link set eth0 addr <MAC>' where
> > '<MAC>' is too long, e.g. '00:11:22:33:44:55:66:77'. Called like this,
> > 'ip' would return successfully and the kernel sets eth0's MAC address to
> > the leading six octets of the passed argument.
> > 
> > Signed-off-by: Phil Sutter <phil@nwl.cc>
> 
> I don't think this behavior is very "dubious" and making the check more
> strict risks breaking things that have worked for a very long time.
> 
> I'm not applying this, sorry.

No problem. I was already afraid of this breaking something as commit
1840bb1, which introduces validate_linkmsg(), already mentions something
in that direction. Therefore I appreciate your feedback clarifying this
for me, although it is not quite the outcome I had wished for.

Seeing that the kernel checks the minimum length already, shifting the
maximum length check to kernel space felt like a natural choice.

Nevertheless, I think iproute2 should not behave this way. Stephen, do
you think it is reasonable to add a similar logic to iplink_parse() as
done in do_set() (i.e., finding out which is the correct length of LL
address for a given interface and validating input based on this)? If
so, is it appropriate to recycle get_address() function or should the
information come from netlink?

Thanks, Phil
