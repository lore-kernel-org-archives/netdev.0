From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] ipv6: Create module parameter for use_tempaddr
Date: Mon, 12 Sep 2011 15:51:45 -0400
Message-ID: <4E6E62D1.8010108@hp.com>
References: <20110901062754.5D1642043D@glenhelen.mtv.corp.google.com>	<CAMcMvsgZ8t=dh5G=QuFKODCyrBX56nveztq=0QBwaUfO46KL9Q@mail.gmail.com> <CAMcMvsja6hmHj3-+vCYLnXXBbGznK9EJbx+mkBgT8gR6iwRoWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Paul Stewart <pstew@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:7681 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751611Ab1ILTvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2011 15:51:48 -0400
In-Reply-To: <CAMcMvsja6hmHj3-+vCYLnXXBbGznK9EJbx+mkBgT8gR6iwRoWg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/12/2011 12:37 PM, Paul Stewart wrote:
> Hello, folks.  I've been trying to upstream (or open a discussion on)
> adding a module parameter to enable IPv6 address privacy as a module
> parameter.  The author listed for if_inet6.c is not a bouncing email
> address.  Does anyone else have a suggestion for where to get this
> change vetted?  I'm now CC'ing the author and reviewer of the last
> module parameter change for ipv6.

I think David would just tell you to be patient, your patch is listed in
patchwork, http://patchwork.ozlabs.org/project/netdev/list/ , and git.kernel.org
is still down...

>>>  static int disable_ipv6_mod = 0;
>>> @@ -89,6 +92,11 @@ MODULE_PARM_DESC(disable_ipv6, "Disable IPv6 on all interfaces");
>>>  module_param_named(autoconf, ipv6_defaults.autoconf, int, 0444);
>>>  MODULE_PARM_DESC(autoconf, "Enable IPv6 address autoconfiguration on all interfaces");
>>>
>>> +#ifdef CONFIG_IPV6_PRIVACY
>>> +module_param_named(use_tempaddr, ipv6_defaults.use_tempaddr, int, 0444);
>>> +MODULE_PARM_DESC(use_tempaddr, "Enable IPv6 address privacy for autoconfiguration by default");
>>> +#endif

I don't know if you want this under an #ifdef, since that could fail a module
load on certain kernel builds - people might want to put the same entry in a
conf file whether the kernel supports it or not (if it's accepted).

And you failed to update Documentation/networking/ipv6.txt

-Brian
