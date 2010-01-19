From: Brian Haley <brian.haley@hp.com>
Subject: Re: Global IPV6 auto-configuration does not work as expected.
Date: Tue, 19 Jan 2010 13:21:04 -0500
Message-ID: <4B55F810.4060406@hp.com>
References: <201001182108.o0IL8nBB029112@wind.enjellic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: greg@enjellic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:35991 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753946Ab0ASSVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 13:21:10 -0500
In-Reply-To: <201001182108.o0IL8nBB029112@wind.enjellic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

greg@enjellic.com wrote:
> On Jan 18,  3:17pm, Neil Horman wrote:
> } Subject: Re: Global IPV6 auto-configuration does not work as expected.
> 
> Hi Neil, thanks for the note.
> 
>>> The only way we have been able to disable the auto-configuration has
>>> been to explicitly disable it at the individual interface level with
>>> net.ipv6.conf.ethN.autoconf=0 directives.

If done after module load, then that's currently the only way to do it.

> The 'sysctl -p' command is issued by the rc.sysinit script very early
> in the boot process.  Long before the interfaces are actually
> 'upped'.  I'm assuming from your description that the:
> 
> net.ipv6.conf.default.autoconf 
> 
> If set to 0 before the network interfaces are configured should
> prevent auto-configuration from occuring.  I will re-test but I don't
> think that is happening.

I can confirm that this works correctly, for example if you set this to
zero then rmmod/modprobe one of your network drivers, you'll see it get
set correctly.

To fix your reported problem, I added a module parameter to control
the setting of autoconf at load time in June 2009
(see Documentation/networking/ipv6.txt).  Basically, just add this to
/etc/modprobe.conf:

	options ipv6 autoconf=0

Your distro might require it somewhere else.

> Also from your description I'm assuming the following:
> 
> net.ipv6.conf.all.autoconf=0
> 
> If set should globally turn off auto-configuration.

Actually, I don't think that's ever done that, the "all" settings only
affects some things, like forwarding, proxy_ndp, and disable_ipv6.

Even if the "all" setting did have control over this, if its setting was 0
and the device setting was 1, shouldn't the device setting override it?

Hope this helps,

-Brian
