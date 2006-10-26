From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC] tcp: setsockopt congestion control autoload
Date: Thu, 26 Oct 2006 18:57:13 +0400
Message-ID: <20061026145712.GA11062@2ka.mipt.ru>
References: <20061025110843.0cbd18a7@freekitty> <20061026052253.GA10188@2ka.mipt.ru> <4540C791.5060200@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:1991 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1423541AbWJZO5R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 10:57:17 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <4540C791.5060200@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 26, 2006 at 07:34:57AM -0700, Stephen Hemminger (shemminger@osdl.org) wrote:
> Evgeniy Polyakov wrote:
> >On Wed, Oct 25, 2006 at 11:08:43AM -0700, Stephen Hemminger 
> >(shemminger@osdl.org) wrote:
> >  
> >>If user asks for a congestion control type with setsockopt() then it
> >>may be available as a module not included in the kernel already. 
> >>It should be autoloaded if needed.  This is done already when
> >>the default selection is change with sysctl, but not when application
> >>requests via sysctl.
> >>
> >>Only reservation is are there any bad security implications from this?
> >>    
> >
> >What if system is badly configured, so it is possible to load malicious
> >module by kernel?
> >
> The kernel module loader has a fixed path. So one would have to be able 
> to create a module
> in /lib/modules/<kernel release> in order to get the malicious code 
> loaded.  If the intruder could
> put a module there, it would be just as easy to patch an existing module 
> and have the
> hack available on reboot.

It just calls /sbin/modprobe, which in turn runs tons of scripts in
/etc/hotplug, modprobe and other places...
In the paranoid case we should not allow any user to load kernel
modules, even known ones. Should this option be guarded by some
capability check?

-- 
	Evgeniy Polyakov
