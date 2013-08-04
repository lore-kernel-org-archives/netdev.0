From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v2 2/2] ip rule: add route suppression options
Date: Sun, 4 Aug 2013 11:56:22 -0700
Message-ID: <20130804115622.0f3d26c7@nehalam.linuxnetplumber.net>
References: <20130803122316.GN21970@zirkel.wertarbyte.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:37855 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753200Ab3HDS4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Aug 2013 14:56:25 -0400
Received: by mail-pd0-f176.google.com with SMTP id q10so2425125pdj.21
        for <netdev@vger.kernel.org>; Sun, 04 Aug 2013 11:56:25 -0700 (PDT)
In-Reply-To: <20130803122316.GN21970@zirkel.wertarbyte.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 3 Aug 2013 14:23:16 +0200
Stefan Tomanek <stefan.tomanek@wertarbyte.de> wrote:

> When configuring a system with multiple network uplinks and default routes, it
> is often convenient to reference a routing table multiple times - but reject
> its routing decision if certain constraints are not met by it.
> 
> Consider this setup:
> 
> $ ip route add table secuplink default via 10.42.23.1
> 
> $ ip rule add pref 100            table main suppress_prefixlength 0
> $ ip rule add pref 150 fwmark 0xA table secuplink
> 
> With this setup, packets marked 0xA will be processed by the additional routing
> table "secuplink", but only if no suitable route in the main routing table can
> be found. By suppressing entries with a prefixlength of 0 (or less), the
> default route (/0) of the table "main" is hidden to packets processed by rule
> 100; packets traveling to destinations via more specific routes are processed
> as usual.
> 
> It is also possible to suppress a routing entry if a device belonging to
> a specific interface group is to be used:
> 
> $ ip rule add pref 150 table main suppress_group 1
> 
> Signed-off-by: Stefan Tomanek <stefan.tomanek@wertarbyte.de>

Applied to net-next-3.11 branch
