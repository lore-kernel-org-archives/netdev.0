From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 07/11] e1000e: cleanup Rx checksum offload code
Date: Tue, 3 Jan 2012 21:24:02 +0000
Message-ID: <1325625842.2832.17.camel@bwh-desktop>
References: <1325618356-2655-8-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20120103.150842.1516759599032629705.davem@davemloft.net>
	 <1325624413.2832.9.camel@bwh-desktop>
	 <20120103.161553.395980097965998086.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <jeffrey.t.kirsher@intel.com>, <bruce.w.allan@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>, <sassmann@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:9977 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754010Ab2ACVYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 16:24:06 -0500
In-Reply-To: <20120103.161553.395980097965998086.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-01-03 at 16:15 -0500, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Tue, 3 Jan 2012 21:00:12 +0000
> 
> > On Tue, 2012-01-03 at 15:08 -0500, David Miller wrote:
> >> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >> Date: Tue,  3 Jan 2012 11:19:12 -0800
> >> 
> >> > -		__sum16 sum = (__force __sum16)htons(csum);
> >> > +		__sum16 sum = (__force __sum16)htons(le16_to_cpu(csum));
> >> 
> >> Looks like a NOP.  It's essentially "cpu_to_le16(le16_to_cpu(csum)" as
> >> far as I can tell.
> > 
> > Looks like a swab() to me...
> 
> I don't see how it can be.  It's effectively doing a 16-bit swap and
> then a 16-bit swap again, which is a NOP.
> 
> It's the same as "(__force __sum16) csum" and I bet if the code above
> works, then this expression I'm suggesting will work too.

In this part of the universe, network order is big-endian.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
