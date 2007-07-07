From: Joel Becker <Joel.Becker@oracle.com>
Subject: Re: [PATCH -mm 9/9] netconsole: Support dynamic reconfiguration using configfs
Date: Sat, 7 Jul 2007 01:18:53 -0700
Message-ID: <20070707081852.GC1011@tasint.org>
References: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in> <20070704110824.28520.11661.sendpatchset@cselinux1.cse.iitk.ac.in> <20070707060114.GB1011@tasint.org> <Pine.LNX.4.64.0707071216450.24470@cselinux1.cse.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Netdev <netdev@vger.kernel.org>, Matt Mackall <mpm@selenic.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:23849 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751362AbXGGIT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jul 2007 04:19:29 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0707071216450.24470@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 07, 2007 at 01:18:45PM +0530, Satyam Sharma wrote:
> However, for items that are statically initialized (often the
> group->cg_item members of subsystems or default groups) we often simply
> set ci_namebuf and then call config_item_init() -- say via
> config_group_init(), like I've done with the netconsole subsystem in this
> patch -- but config_item_init() does not set ci_name for such items to
> ci_namebuf. This means the ci_name member of _initialized_ config_items
> with their names in ci_namebuf is left un-initialized (NULL, actually,
> because the subsys / default group would likely be static).

	Configfs notices subsystems and default groups and handles this.
See configfs_register_subsystem() and create_default_group() in
fs/configfs/dir.c

> Right. We shouldn't special case (at least not without adding a comment
> why that would be right) and we never know what might happen to the code
> at some later day. So let's keep the get() / put() pair.

	If you're keeping them, don't do the "empty_item", check the
name.
	Otherwise, the changes you describe sound good.

Joel


-- 

"I have never let my schooling interfere with my education."
        - Mark Twain

Joel Becker
Principal Software Developer
Oracle
E-mail: joel.becker@oracle.com
Phone: (650) 506-8127
