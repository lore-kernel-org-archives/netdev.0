From: greg@enjellic.com
Subject: Re: Global IPV6 auto-configuration does not work as expected.
Date: Tue, 19 Jan 2010 14:34:00 -0600
Message-ID: <201001192034.o0JKY0OO001470@wind.enjellic.com>
References: <brian.haley@hp.com>
Reply-To: greg@enjellic.com
Cc: Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Brian Haley <brian.haley@hp.com>, greg@enjellic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wind.enjellic.com ([209.243.13.15]:45372 "EHLO
	wind.enjellic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753847Ab0ASUeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 15:34:19 -0500
In-Reply-To: Brian Haley <brian.haley@hp.com>
       "Re: Global IPV6 auto-configuration does not work as expected." (Jan 19,  1:21pm)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 19,  1:21pm, Brian Haley wrote:
} Subject: Re: Global IPV6 auto-configuration does not work as expected.

Hi Brian, thanks for the note.

> greg@enjellic.com wrote:
> > On Jan 18,  3:17pm, Neil Horman wrote:
> > } Subject: Re: Global IPV6 auto-configuration does not work as expected.
> > 
> > Hi Neil, thanks for the note.
> > 
> >>> The only way we have been able to disable the auto-configuration has
> >>> been to explicitly disable it at the individual interface level with
> >>> net.ipv6.conf.ethN.autoconf=0 directives.

> If done after module load, then that's currently the only way to do it.

Well that is probably the root of the problem.  We only use statically
compiled custom kernels.  Based on that it would seem that our only
alternative is to use the interface specific directive.

Or hack the kernel sources to neuter it.

> > The 'sysctl -p' command is issued by the rc.sysinit script very early
> > in the boot process.  Long before the interfaces are actually
> > 'upped'.  I'm assuming from your description that the:
> > 
> > net.ipv6.conf.default.autoconf 
> > 
> > If set to 0 before the network interfaces are configured should
> > prevent auto-configuration from occuring.  I will re-test but I don't
> > think that is happening.

> I can confirm that this works correctly, for example if you set this to
> zero then rmmod/modprobe one of your network drivers, you'll see it get
> set correctly.
> 
> To fix your reported problem, I added a module parameter to control
> the setting of autoconf at load time in June 2009
> (see Documentation/networking/ipv6.txt).  Basically, just add this to
> /etc/modprobe.conf:
> 
> 	options ipv6 autoconf=0
> 
> Your distro might require it somewhere else.

That would only be effective with a modular implementation of ipv6.
As I noted above these are completely static kernels.

I will have to take a look at the source.  I would assume the IPv6
code is looking at that variable.  It may be a straight forward
exercise to just unconditionally disable it for these static kernels.

Thoughts?

> > Also from your description I'm assuming the following:
> > 
> > net.ipv6.conf.all.autoconf=0
> > 
> > If set should globally turn off auto-configuration.

> Actually, I don't think that's ever done that, the "all" settings only
> affects some things, like forwarding, proxy_ndp, and disable_ipv6.
> 
> Even if the "all" setting did have control over this, if its setting was 0
> and the device setting was 1, shouldn't the device setting override
> it?

Good question, somewhat of a chicken and egg problem.

Right now the the interpretation of all this seems to be somewhat
muddled.  I've been doing this for a long time and the current
behavior had me confused.

It seems to me there should be some type of conditional knob, arguably
in the sysctl infra-structure which can make auto-configuration go
away, modular kernel or not.

> Hope this helps,
> 
> -Brian

I do appreciate the insight.  At least we are not fumbling around
trying to figure out if we are using this stuff wrong.

Have a good evening.

}-- End of excerpt from Brian Haley

As always,
Dr. G.W. Wettstein, Ph.D.   Enjellic Systems Development, LLC.
4206 N. 19th Ave.           Specializing in information infra-structure
Fargo, ND  58102            development.
PH: 701-281-1686
FAX: 701-281-3949           EMAIL: greg@enjellic.com
------------------------------------------------------------------------------
"I can only provide the information, I can't make you hear it."
                                -- Shelley Bainter
