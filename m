From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC] tcp: setsockopt congestion control autoload
Date: Thu, 26 Oct 2006 08:23:14 -0700
Message-ID: <20061026082314.1dcea52c@freekitty>
References: <20061025110843.0cbd18a7@freekitty>
	<20061026052253.GA10188@2ka.mipt.ru>
	<4540C791.5060200@osdl.org>
	<20061026145712.GA11062@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:53889 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1423557AbWJZP23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 11:28:29 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061026145712.GA11062@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 26 Oct 2006 18:57:13 +0400
Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:

> On Thu, Oct 26, 2006 at 07:34:57AM -0700, Stephen Hemminger (shemminger@osdl.org) wrote:
> > Evgeniy Polyakov wrote:
> > >On Wed, Oct 25, 2006 at 11:08:43AM -0700, Stephen Hemminger 
> > >(shemminger@osdl.org) wrote:
> > >  
> > >>If user asks for a congestion control type with setsockopt() then it
> > >>may be available as a module not included in the kernel already. 
> > >>It should be autoloaded if needed.  This is done already when
> > >>the default selection is change with sysctl, but not when application
> > >>requests via sysctl.
> > >>
> > >>Only reservation is are there any bad security implications from this?
> > >>    
> > >
> > >What if system is badly configured, so it is possible to load malicious
> > >module by kernel?
> > >
> > The kernel module loader has a fixed path. So one would have to be able 
> > to create a module
> > in /lib/modules/<kernel release> in order to get the malicious code 
> > loaded.  If the intruder could
> > put a module there, it would be just as easy to patch an existing module 
> > and have the
> > hack available on reboot.
> 
> It just calls /sbin/modprobe, which in turn runs tons of scripts in
> /etc/hotplug, modprobe and other places...
> In the paranoid case we should not allow any user to load kernel
> modules, even known ones. Should this option be guarded by some
> capability check?
> 

No capability check needed. Any additional paranoia belongs in /sbin/modprobe.

There seems to be lots of existing usage where a user can cause a module
to be loaded (see bin_fmt, xtables, etc).

-- 
Stephen Hemminger <shemminger@osdl.org>
