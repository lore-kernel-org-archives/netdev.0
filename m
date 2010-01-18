From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Global IPV6 auto-configuration does not work as expected.
Date: Mon, 18 Jan 2010 17:30:38 -0500
Message-ID: <20100118223038.GA17767@hmsreliant.think-freely.org>
References: <nhorman@tuxdriver.com>
 <201001182108.o0IL8nBB029112@wind.enjellic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: greg@enjellic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56463 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755627Ab0ARWan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 17:30:43 -0500
Content-Disposition: inline
In-Reply-To: <201001182108.o0IL8nBB029112@wind.enjellic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 18, 2010 at 03:08:49PM -0600, greg@enjellic.com wrote:
> On Jan 18,  3:17pm, Neil Horman wrote:
> } Subject: Re: Global IPV6 auto-configuration does not work as expected.
> 
> Hi Neil, thanks for the note.
> 
> > > The only way we have been able to disable the auto-configuration has
> > > been to explicitly disable it at the individual interface level with
> > > net.ipv6.conf.ethN.autoconf=0 directives.
> > > 
> > > We've noted the net.ipv6.conf.default.autoconf and experimented with
> > > that a bit as well but haven't been able to accomplish our objective.
> > > 
> > > Thoughts?
> > > 
> > > Best wishes for a productive week.
> > > 
> 
> > First guess would be that you have autoconf configured for you
> > interfaces in the config files.  The default sysctl directory just
> > controls the state of the device when its first registered, while
> > the all sysctl directory provides a 1-shot mechanism to affect the
> > state of all devices at once.  Neither prevents autoconfiguration
> > from getting set on devices when udev responds to their creation.
> > Do the following:
> >
> > 1) cd /etc/sysconfig/network-scripts
> > 2) grep IPV6_AUTOCONF ifcfg*
> > 
> > If you get any results in step 2 that read like this:
> > IPV6_AUTOCONF=yes
> > 
> > Then your configuration is teling the system to enable autoconf on those
> > interfaces.  You can correct that by removing those lines from those config
> > file, or changing them to:
> > IPV6_AUTOCONF=no
> 
> The boxes are not running any of the standard distributions.  They are
> running a very minimalistic distribution that I put together in early
> 1992 and have been maintaining ever since.... :-) So the network
> configuration script isn't playing a role in this.
> 
Um, wow, ok.  What kernel version is this running?  Are you managing any udev
events?

> The 'sysctl -p' command is issued by the rc.sysinit script very early
> in the boot process.  Long before the interfaces are actually
> 'upped'.  I'm assuming from your description that the:
> 
> net.ipv6.conf.default.autoconf 
> 
> If set to 0 before the network interfaces are configured should
> prevent auto-configuration from occuring.  I will re-test but I don't
> think that is happening.
> 
Only if nothing else changes the default on a per-interface basis.  Hence my
comment regarding the use of network config scripts.

If you set the default value of autoconf, then insmod a network driver that
registers (for example) eth0, what does /proc/sys/net/ipv6/conf/eth0/autoconf
contain?  If its 0, then you should be good.  If its 1, then something else is
afoot, changing the config value.

> Also from your description I'm assuming the following:
> 
> net.ipv6.conf.all.autoconf=0
> 
> If set should globally turn off auto-configuration.
> 
As a 1-shot, yes, but again, that doesn't stop someone from overriding it after
its issued.  Its the same as doing this:
for i in `every interface`
do
	echo 0 > /proc/sys/net/ipv6/conf/$i/autoconf
done


> I just tested that again.  After setting the 'all' directive to zero I
> removed the IPv6 addresses and after a short time the were
> auto-configured again.
> 
> For good measure I also set net.ipv6.conf.default.autoconf=0 and
> removed the IPv6 addresses.  With both directives set to 0 the IPv6
> autoconf address returned.
> 
> I'm certainly not discounting user error but according to your
> description the net.ipv6.conf.all.autoconf=0 should globally disable
> auto-configuration on the interfaces, yet it doesn't seem to.  Unless
> the interfaces need to be 'downed' and 'upped' after the sysctl value
> is set but that seems counter-intuitive.
> 
What address values are you seeing on here?
Neil

> > Best
> > Neil
> 
> Greg
> 
> }-- End of excerpt from Neil Horman
> 
> As always,
> Dr. G.W. Wettstein, Ph.D.   Enjellic Systems Development, LLC.
> 4206 N. 19th Ave.           Specializing in information infra-structure
> Fargo, ND  58102            development.
> PH: 701-281-1686
> FAX: 701-281-3949           EMAIL: greg@enjellic.com
> ------------------------------------------------------------------------------
> "Programming without software engineering is like sculpting with a
>  chain saw.  The very talented can produce a work of art, the mediocre
>  wind up with a misshapen lump in a pile of rubble, and in neither case
>  does the end result have more than a passing resemblance to the
>  original intent."
>                                 -- Bill Davidsen
> 
