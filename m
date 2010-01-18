From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Global IPV6 auto-configuration does not work as expected.
Date: Mon, 18 Jan 2010 15:17:54 -0500
Message-ID: <20100118201754.GA1597@hmsreliant.think-freely.org>
References: <201001181906.o0IJ66mG028647@wind.enjellic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: greg@enjellic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:45503 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751753Ab0ARUSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 15:18:00 -0500
Content-Disposition: inline
In-Reply-To: <201001181906.o0IJ66mG028647@wind.enjellic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 18, 2010 at 01:06:06PM -0600, greg@enjellic.com wrote:
> Good afternoon, hope this note finds everyone's week starting well.
> 
> We are in the process of beginning full scale deployment of IPv6 and
> have run into the following issue.  It is probably user error so feel
> free to note it as such.
> 
> We want to turn off auto-configuration of IPv6 by our routers on all
> interfaces on our servers.  From a bit of Googling and intuition we
> assumed the following sysctl key would do this:
> 
> net.ipv6.conf.all.autoconf=0
> 
> But this seems to have no effect.  We have booted the machines and set
> the above directive before the network configures and have also tried
> setting the directive after boot followed by manual deletion of the
> router assigned addresses but they keep returning.  It's happening
> with 2.6.31.x and 2.6.32.x kernels.
> 
> The only way we have been able to disable the auto-configuration has
> been to explicitly disable it at the individual interface level with
> net.ipv6.conf.ethN.autoconf=0 directives.
> 
> We've noted the net.ipv6.conf.default.autoconf and experimented with
> that a bit as well but haven't been able to accomplish our objective.
> 
> Thoughts?
> 
> Best wishes for a productive week.
> 

First guess would be that you have autoconf configured for you interfaces in the
config files.  The default sysctl directory just controls the state of the
device when its first registered, while the all sysctl directory provides a
1-shot mechanism to affect the state of all devices at once.  Neither prevents
autoconfiguration from getting set on devices when udev responds to their
creation.  Do the following:
1) cd /etc/sysconfig/network-scripts
2) grep IPV6_AUTOCONF ifcfg*

If you get any results in step 2 that read like this:
IPV6_AUTOCONF=yes

Then your configuration is teling the system to enable autoconf on those
interfaces.  You can correct that by removing those lines from those config
file, or changing them to:
IPV6_AUTOCONF=no

Best
Neil

