From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] natsemi: make cable length magic configurable
Date: Mon, 16 Jul 2012 14:08:54 +0100
Message-ID: <1342444134.2523.4.camel@bwh-desktop.uk.solarflarecom.com>
References: <201111241443.59191.jdelvare@suse.de>
	 <1322162739.2784.26.camel@bwh-desktop>
	 <1342441581.4165.235.camel@amber.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Tim Hockin <thockin@hockin.org>,
	Olaf Kirch <okir@suse.de>
To: Jean Delvare <jdelvare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:33926 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751808Ab2GPNJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 09:09:02 -0400
In-Reply-To: <1342441581.4165.235.camel@amber.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-16 at 14:26 +0200, Jean Delvare wrote:
[...]
> > You would need to:
> > 1. Number the flags starting from 0.  Well, that was easy.
> > 2. Implement {get,set}_priv_flags() operations to access all flags as
> >    a bitmask.
> > 3. Expose the flag names as string set ETH_SS_PRIV_FLAGS accessed by
> >    get_sset_count() and get_strings() operations.
> 
> I was looking for an example, but there doesn't seem to be any driver
> implementing private flags at the moment?

No.

> I am also unsure if a private flag is a suitable solution to the problem
> at hand. I am a little worried about the timing, as the non-default
> value can't be set before the network device is available, I'm afraid
> the network initialization scripts may kick in before one has a chance
> to set the flag with ethtool. I suppose this could be problematic, but
> then again I don't know much about network device drivers, I don't even
> know for sure when method .ndo_open is called...

It's called when the interface is brought up (ifconfig up, ip link set
up, start NetworkManager...).  Some distributions provide a
configuration option(s) to run ethtool while bringing an interface up.

> Furthermore I don't quite get why we can't just go with the module
> parameter. As I understand it, this is a crappy driver for crappy, rare
> hardware. The driver already has a module parameter to work around a
> hardware bug (dspcfg_workaround), I don't quite see why adding a second
> one would be a problem. At least it is consistent.

David can be quite insistent about finding an alternative to module
parameters.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
