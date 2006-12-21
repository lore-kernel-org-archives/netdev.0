From: Daniel Drake <dsd@gentoo.org>
Subject: Re: Network drivers that don't suspend on interface down
Date: Wed, 20 Dec 2006 21:29:35 -0500
Message-ID: <4589F18F.1090703@gentoo.org>
References: <20061220042648.GA19814@srcf.ucam.org> <200612192114.49920.david-b@pacbell.net> <20061220053417.GA29877@suse.de> <20061220055209.GA20483@srcf.ucam.org> <1166601025.3365.1345.camel@laptopd505.fenrus.org> <20061220125314.GA24188@srcf.ucam.org> <1166621931.3365.1384.camel@laptopd505.fenrus.org> <20061220143134.GA25462@srcf.ucam.org> <1166629900.3365.1428.camel@laptopd505.fenrus.org> <20061220144906.7863bcd3@dxpl.pdx.osdl.net> <20061221011209.GA32625@srcf.ucam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Arjan van de Ven <arjan@infradead.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161144AbWLUC2x@vger.kernel.org>
To: Matthew Garrett <mjg59@srcf.ucam.org>
In-Reply-To: <20061221011209.GA32625@srcf.ucam.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matthew Garrett wrote:
> Veering off at something of a tangent - how much of this should be true 
> for wireless devices? Softmac seems to be unhappy about setting the 
> essid unless the card is up, which breaks various assumptions...

You might regard that as a bug - I agree it probably makes sense for you 
to be able to set certain configuration variables before the interface 
is up, within reason.

However, the mentality adopted by most wireless drivers is the SIWESSID 
wireless extension ioctl means *associate*, something which obviously 
shouldn't be possible when the interface is down (radio off, etc).

While you might blame drivers for this possible misinterpretation, it 
can also be viewed as a design flaw in WE: the drivers have to handle 
the ioctl's directly, meaning that if you want some kind of 
configuration management then you have to do it on the driver level, and 
this doesn't feel right.

The situation is also made worse due to WE generally being hard to 
implement, and also the lack of documentation (really the only source 
here is the iwconfig man page).

This screams out for an 802.11-centric configuration system, and it 
looks like we have one on the way: cfg80211
 From reading some mails, it looks like the drivers will simply have to 
provide functions for "associate", "scan", etc, and the configuration 
management will be offloaded to the upper layers.

For the time being, I suggest you bring the interface up before setting 
the configuration. Regardless of the inconsistency of the current 
situation, and lack documentation saying which way it should be done, 
you are at least playing it safe and guaranteeing it works on all drivers.

Daniel
