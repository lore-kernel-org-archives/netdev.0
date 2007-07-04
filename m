From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH -mm 2/9] netconsole: Code simplification
Date: Wed, 4 Jul 2007 08:46:18 -0500
Message-ID: <20070704134618.GA11115@waste.org>
References: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in> <20070704110749.28520.92997.sendpatchset@cselinux1.cse.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:36683 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758986AbXGDNra (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jul 2007 09:47:30 -0400
Content-Disposition: inline
In-Reply-To: <20070704110749.28520.92997.sendpatchset@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 04, 2007 at 04:37:49PM +0530, Satyam Sharma wrote:
> From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
> 
> [2/9] netconsole: Code simplification
> 
> (1) Extract netpoll_parse_options() out of option_setup(), and into
> init_netconsole() itself. So "configured" variable is redundant and
> can be removed.
> 
> (2) With this change, option_setup() is not required for modular netconsole.

How is this a simplification? You've taken code with no #ifdefs and
added one! Please have both modular and nonmodular continue to use the
same paths.

> 
> (3) The (!np.dev) check in write_msg() is bogus (always false), because:
> np.dev is set by netpoll_setup(), which is called by the target init
> code in init_netconsole() _before_ register_console() => write_msg() cannot
> be triggered unless netpoll_setup() returns with success. And that will not
> happen if netpoll_setup() failed to set np.dev. Also np.dev cannot go from
> under us while netconsole is loaded. This is because netpoll_setup() grabs
> a reference for us on that dev. So let's remove the pointless check.

This ought to be a separate patch.

-- 
Mathematics is the supreme nostalgia of our time.
