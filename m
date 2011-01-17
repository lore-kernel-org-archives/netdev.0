From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] dummy: do not create a link (dummy0) at module init by
 default
Date: Mon, 17 Jan 2011 08:56:42 -0800
Message-ID: <20110117085642.0dddd66e@nehalam>
References: <1295225393-5779-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ward <david.ward@ll.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44185 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752128Ab1AQQ4p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Jan 2011 11:56:45 -0500
In-Reply-To: <1295225393-5779-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 16 Jan 2011 19:49:53 -0500
David Ward <david.ward@ll.mit.edu> wrote:

> When the dummy network driver is initialized with no parameters, a link
> is automatically created (named 'dummy0'). This is inconsistent with
> other virtual network drivers such as veth, macvlan, and macvtap, which
> do not create a link upon initialization.
> 
> This also causes confusing behavior when sending an RTM_NEWLINK message
> for a dummy link, because the kernel will load the dummy network driver
> first if it has not already been loaded. When that occurs, the result
> is that two new links are actually created (or if IFLA_IFNAME is set to
> 'dummy0', the error EEXIST is returned). The following iproute command
> demonstrates this behavior:
> 
>   ip link add [ name dummy0 ] type dummy
> 
> With this change, users who still want to have a link created when the
> dummy network driver is loaded (instead of using iproute to create the
> link as shown above) just need to set the 'numdummies' parameter to 1:
> 
>   modprobe dummy numdummies=1
> 
> Signed-off-by: David Ward <david.ward@ll.mit.edu>

I understand what you are trying to do, and it makes sense.
But because of the history behind this it can't change.
We can't change existing API and break user scripts.

The 'ip link' command support is new (in last couple of years), and
the module parameter has been around since early days.

If you want to load module without any devices just use:
  modprobe dummy numdummies=0


-- 
