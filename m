From: Stefan Rompf <stefan@loplof.de>
Subject: Re: [NETLINK]: Schedule removal of old macros exported to userspace
Date: Sun, 10 Dec 2006 11:11:32 +0100 (MET)
Message-ID: <200612101109.34149.stefan@loplof.de>
References: <20061208.164345.71119524.davem@davemloft.net>
 <20061209.134552.71105673.davem@davemloft.net>
 <20061209232805.GP8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain;  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, drow@false.org,
	dwmw2@infradead.org, joseph@codesourcery.com,
	netdev@vger.kernel.org, libc-alpha@sourceware.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p07-ob.rzone.de ([81.169.146.190]:22204 "EHLO
	mo-p07-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760625AbWLJKLv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Dec 2006 05:11:51 -0500
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20061209232805.GP8693@postel.suug.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Am Sonntag, 10. Dezember 2006 00:28 schrieb Thomas Graf:

> I had a short glance at dhcpclient's netlink code and found half
> a dozen bugs within five minutes all caused by cut and pasting
> sniplets from other netlink code.

Please send me the list of bugs you've spotted. Of course I want to fix them.

> It is my opinion that people 
> will continue to drag along bugs this way unless the interface is
> removed. I never believed in providing backward compatibility to
> broken code.

My main problem with netlink was missing or wrong documentation (and yes, I 
know it's much easier writing code than writing docs, especially if OSS 
development is just a hobby). F.e. until 2.6.19 it has not been possible to 
query one ifi_index with RTM_GETLINK even though rfc3549 specified this 
operation. Instead, the application had to dump all interfaces and filter the 
record it is interested in. Stuff like this creates much more bugs than a 
non-typesafe macro because it makes you think "Damn it's working now, never 
touch that code again".

Don't take this as an offense, I do value your work and will use libnl for 
future projects, but I definitely do not share your opinion on how to deal 
with ugly/obsolete userspace interfaces (even though this one is not 
obsolete, because it is the only low level interface that exists at all).

Stefan
