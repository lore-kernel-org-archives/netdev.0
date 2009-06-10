From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: 8139cp vs 8139too, request_module ?
Date: Wed, 10 Jun 2009 18:00:06 +0100
Message-ID: <1244653206.2848.15.camel@achroite>
References: <1244649729.14601.1.camel@plop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pascal Terjan <pterjan@mandriva.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:51651 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754843AbZFJRAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 13:00:09 -0400
In-Reply-To: <1244649729.14601.1.camel@plop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-06-10 at 18:02 +0200, Pascal Terjan wrote:
> Hello,
> 8139cp and 8139too both handle the same id and then test revision.
> 
> If revision is wrong they tell to load the other module and return
> ENODEV.
> 
> Why not doing a request_module instead of printing a message ? 

The kernel requests a module to handle each PCI device it doesn't
already have a driver for.  modprobe will then load all modules that
match that PCI device and vendor id.  So 8139cp and 8139too are both
loaded for PCI devices that might be handled by either.  There is no
need for them to try to load each other, and  I suspect there would be a
risk of deadlock if they did.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

