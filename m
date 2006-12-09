From: Stefan Rompf <stefan@loplof.de>
Subject: Re: [NETLINK]: Schedule removal of old macros exported to userspace
Date: Sat, 9 Dec 2006 12:49:34 +0100 (MET)
Message-ID: <200612091249.39302.stefan@loplof.de>
References: <20061208.134752.131916271.davem@davemloft.net>
 <20061208.171455.11932070.davem@davemloft.net>
 <20061209103953.GN8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain;  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, drow@false.org,
	dwmw2@infradead.org, joseph@codesourcery.com,
	netdev@vger.kernel.org, libc-alpha@sourceware.org, akpm@osdl.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p07-ob.rzone.de ([81.169.146.188]:37036 "EHLO
	mo-p07-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967811AbWLILwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Dec 2006 06:52:09 -0500
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20061209103953.GN8693@postel.suug.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Samstag, 9. Dezember 2006 11:39 schrieb Thomas Graf:

[Added linux-kernel to CC]

> Index: net-2.6/Documentation/feature-removal-schedule.txt
> ===================================================================
> --- net-2.6.orig/Documentation/feature-removal-schedule.txt	2006-12-09

NAK.

> +What:  Netlink message and attribute parsing macros
> +When:  July 2007
> +Why:   The old interface which often lead to buggy code has been replaced
> +       with a new type safe interface. Parts of this interface, mainly
> +       macros, has been exported to userspace via linux/netlink.h and
> +       linux/rtnetlink.h. Use of this interface is discontinued, all
> helper +       and utility macros will be removed. Userspace applications
> should use +       one of the available libraries.
> +Who:   Thomas Graf <tgraf@suug.ch>

So glibc should be linked to libnl that depends on glibc to compile? Be 
serious!

I see a worrying tendency of kernel developers trying to push their 
stable-api-is-nonsense approach to userspace. You cannot just go ahead and 
remove userspace API that has been exported for years in a six month period. 
99,9% of application developers are not even aware that 
feature-removal-schedule.txt exists. Sorry, these macros will have to stay 
for *years*, even though they are ugly.

Btw, do you know why I didn't realize the breakage before a user alerted me? I 
stopped testing and running every new kernel. Reason? It was stated that 
2.6.18 requires a mandatory upgrade of udev bloat. Last time I needed to 
compile a new udev because of incompatible sysfs changes, it took me over 
three hours to get my notebook running again. Considering that I need to do 
actual money earning work on that system, 2.6.17.x runs nicely and has no new 
bugs that concern me, I just keep using it. Collateral damage.

You know, I'm not so happy with the in kernel stable-api-is-nonsense approach 
because it does create insecurity for developers and therefore bugs. Anyway, 
I accept it, I'm just a part time kernel hacker. But behaving towards 
applications developers this way is *deadly* for linux acceptance! Stuff like 
KDE, or a postgres database server, or whatever is complex enough that 
developers don't have time to follow userspace breakage introduced just 
because of ugly macros.

Stefan
