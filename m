From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [patch net-next V8] net: introduce ethernet teaming device
Date: Mon, 14 Nov 2011 12:31:57 -0500
Message-ID: <20111114173157.GE20605@gospo.rdu.redhat.com>
References: <1321085808-6871-1-git-send-email-jpirko@redhat.com> <20111113.160951.1905657808657009542.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jpirko@redhat.com, netdev@vger.kernel.org, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com, fubar@us.ibm.com,
	andy@greyhouse.net, tgraf@infradead.org, ebiederm@xmission.com,
	mirqus@gmail.com, kaber@trash.net, greearb@candelatech.com,
	jesse@nicira.com, fbl@redhat.com, benjamin.poirier@gmail.com,
	jzupka@redhat.com, ivecera@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44083 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755503Ab1KNRcN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Nov 2011 12:32:13 -0500
Content-Disposition: inline
In-Reply-To: <20111113.160951.1905657808657009542.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 13, 2011 at 04:09:51PM -0500, David Miller wrote:
> From: Jiri Pirko <jpirko@redhat.com>
> Date: Sat, 12 Nov 2011 09:16:48 +0100
> 
> > This patch introduces new network device called team. It supposes to be
> > very fast, simple, userspace-driven alternative to existing bonding
> > driver.
> > 
> > Userspace library called libteam with couple of demo apps is available
> > here:
> > https://github.com/jpirko/libteam
> > Note it's still in its dipers atm.
> > 
> > team<->libteam use generic netlink for communication. That and rtnl
> > suppose to be the only way to configure team device, no sysfs etc.
> > 
> > Python binding of libteam was recently introduced.
> > Daemon providing arpmon/miimon active-backup functionality will be
> > introduced shortly. All what's necessary is already implemented in
> > kernel team driver.
> > 
> > Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> 
> Applied, thanks for all of your hard work.

I'm a bit surprised by this.  Not only is this new function currently
difficult to setup (it took me over an hour to go from a a fresh F16
install to one that had all the necessary libraries and tools to even
configure a team device for the first time), but I was able to cause an
Oops with v8 in only a few minutes of testing.

I have no problem with this functionality as an add-on and possibly
future replacement to some of what currently exists with bonding, but it
seems like what is included in the initial support should should:

1. Not panic easily.
2. Have userspace bits in place to actually test all the proposed kernel
code.  (Jiri admits there is no way to verify the active-backup code).
3. Have some known, published test results.

I hope Jiri will reconsider having a separate team tree for the next few
weeks or months until these issues are worked out.  I think the hard
work will pay off and it is close to being ready; it just doesn't seem
like it is right now.
