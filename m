From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of
 IRQF_SAMPLE_RANDOM
Date: Thu, 15 May 2008 14:04:08 -0400
Message-ID: <482C7B18.6060003@garzik.org>
References: <Pine.LNX.4.62.0805150009060.18303@ikari.dreamhost.com> <20080515142154.0595e475@core> <36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Chris Peterson <cpeterso@cpeterso.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43079 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751350AbYEOSEN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2008 14:04:13 -0400
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brandeburg, Jesse wrote:
> we've been hearing rumblings of big customers wanting (maybe requiring)
> wired network drivers from Intel to  advertise this flag.  Jeff have you
> heard of such?

I do indeed hear requests all the time, from people who want to make 
their boxes externally exploitable.  :)


> I think the argument is that a headless system (no keyboard/mouse, no
> soundcard, probably no video) with a libata based driver and a network
> driver without IRQF_SAMPLE_RANDOM has *no* sources of entropy.  In this
> case the argument is very strong for at least *some* source of entropy
> from interrupts so that randomness can get some external input.  Just
> try rebuilding a kernel RPM over an ssh session and you'll see what I
> mean.

There are entropy sources on a headless box, even one without audio and 
video, that are more secure than adding IRQF_SAMPLE_RANDOM to network 
drivers.

EGD demonstrates this, for example:  http://egd.sourceforge.net/  It 
looks at snmp, w, last, uptime, iostats, vmstats, etc.

And there are plenty of untapped entropy sources even so, such as 
reading temperature sensors, fan speed sensors on variable-speed fans, etc.

Heck, "smartctl -d ata -a /dev/FOO" produces output that could be hashed 
and added as entropy.

I'm interested to hear peoples' opinion of Chris P's patch, but 
definitely do not want to go in the other direction and start adding 
IRQF_SAMPLE_RANDOM, thus moving randomness in the direction of being 
externally exploitable.

	Jeff



