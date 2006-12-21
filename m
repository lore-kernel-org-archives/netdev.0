From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: Network drivers that don't suspend on interface down
Date: Wed, 20 Dec 2006 18:10:49 -0800
Message-ID: <4807377b0612201810t66218e4u4089df818129f1ce@mail.gmail.com>
References: <20061219185223.GA13256@srcf.ucam.org>
	 <20061220042648.GA19814@srcf.ucam.org>
	 <200612192114.49920.david-b@pacbell.net>
	 <20061220053417.GA29877@suse.de>
	 <20061220055209.GA20483@srcf.ucam.org>
	 <1166601025.3365.1345.camel@laptopd505.fenrus.org>
	 <20061220125314.GA24188@srcf.ucam.org>
	 <1166621931.3365.1384.camel@laptopd505.fenrus.org>
	 <20061220143134.GA25462@srcf.ucam.org>
	 <1166629900.3365.1428.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Matthew Garrett" <mjg59@srcf.ucam.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:11021 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161143AbWLUCKw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Dec 2006 21:10:52 -0500
Received: by ug-out-1314.google.com with SMTP id 44so2449169uga
        for <netdev@vger.kernel.org>; Wed, 20 Dec 2006 18:10:49 -0800 (PST)
To: "Arjan van de Ven" <arjan@infradead.org>
In-Reply-To: <1166629900.3365.1428.camel@laptopd505.fenrus.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/20/06, Arjan van de Ven <arjan@infradead.org> wrote:
>
> > Yeah, I guess that's a problem. From a user perspective, the
> > functionality is only really useful if the latency is very small. I
> > think where possible we'd want to power down the chip while keeping the
> > phy up, but it would be nice to know how much power that would actually
> > cost us.
>
> I'm no expert but afaik the PHY is the power hungry part, the rest is
> peanuts. So if we can get the PHY to sleep most of the time that would
> be great.

The MAC uses some part of power, but FYI at least e1000 already does
phy power management when IF_DOWN, if wake on lan isn't enabled, smbus
isn't enabled, etc etc.  If we started using D3 power management its
possible a whole bunch of code would go away out of e1000.

Is there some reason why we can't have the OS just do the D3
transition for all drivers that register support?  I mean, this power
management using D states is actually driver *independent* and at
least way back in the day was supposed to be implemented for "OS power
management"
