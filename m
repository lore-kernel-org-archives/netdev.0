From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] rtnetlink: return the newly created link in response to
 newlink
Date: Thu, 30 Jan 2014 14:27:40 +0000
Message-ID: <20140130142740.GC2185@casper.infradead.org>
References: <1391087144-24490-1-git-send-email-teg@jklm.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	"David S. Miller" <davem@davemloft.net>
To: Tom Gundersen <teg@jklm.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50051 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752572AbaA3O1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jan 2014 09:27:43 -0500
Content-Disposition: inline
In-Reply-To: <1391087144-24490-1-git-send-email-teg@jklm.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/30/14 at 02:05pm, Tom Gundersen wrote:
> Userspace needs to reliably know the ifindex of the netdevs it creates,
> as we cannot rely on the ifname staying unchanged.
> 
> Earlier, a simlpe NLMSG_ERROR would be returned, but this returns the
> corresponding RTM_NEWLINK on success instead.

This breaks existing Netlink applications in user space. User space
apps are not prepared to receive both a RTM_NEWLINK reply _and_
the ACK unless they have set NLM_F_ECHO in the original request.

You can already reliably retrieve the ifindex by listening to
RTNLGRP_LINK messages and be notified about the link created
including all follow-up renames.
