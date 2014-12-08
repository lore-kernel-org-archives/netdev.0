From: Dan Williams <dcbw@redhat.com>
Subject: Re: wl1251: NVS firmware data
Date: Mon, 08 Dec 2014 16:41:33 -0600
Message-ID: <1418078493.31640.4.camel@dcbw.local>
References: <201411271506.20457@pali> <201412081811.46943@pali>
		 <30072B9E-2495-4F90-AC91-9C0D7E08F44E@holtmann.org>
		 <201412082015.18501@pali> <1418066813.1350.18.camel@dcbw.local>
	 <5485FF17.1070504@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pali =?ISO-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Ming Lei <ming.lei@canonical.com>, Pavel Machek <pavel@ucw.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Grazvydas Ignotas <notasas@gmail.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Aaro Koskinen <aaro.koskinen@iki.fi>,
	Kalle Valo <kvalo@adurom.com>,
	Sebastian Reichel <sre@ring0.de>,
	David Gnedt <david.gnedt@davizone.at>
To: Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51965 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754656AbaLHWm1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Dec 2014 17:42:27 -0500
In-Reply-To: <5485FF17.1070504@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-12-08 at 21:42 +0200, Ivaylo Dimitrov wrote:
> 
> On  8.12.2014 21:26, Dan Williams wrote:
> >
> > a) change driver to prefer a new "wl1251-nvs-n900.bin" file, but fall
> > back to "wl1251-nvs.bin" if the first one isn't present
> > b) have a "wl1251-cal-nvs-update" service that, if wl1521-nvs-n900.bin
> > is *not* present mounts the CAL MTD, reads the data, writes it out into
> > wl1521-nvs-n900.bin, and the rmmod/modprobes the driver
> >
> > and done?  Stuff that's not N900 just wouldn't ship the update service
> > and would proceed like none of this happened.
> >
> > Dan
> >
> >
> 
> That would mean that the driver should not be built-in, as afaik we 
> cannot rmmod built-in drivers. Sure, it will work after a reboot, but 
> this is a bit hacky, agree?
> 
> Also, new NVS file needs to be loaded when fcc regulation changes(flying 
> abroad), so that would mean that the device would be outside of those 
> until reboot (in case of built-in driver)

Regulatory stuff needs to be hooked into CRDA or the existing regulatory
codepaths, not some other path.  So when cfg80211 sets the regulatory
domain on the driver the driver needs to get the necessary NVS data.
Either the NVS for every domain (which cannot be a lot of them) gets
hardcoded into the driver, and then selected based on what cfg80211
says, or the driver needs to ask userspace for the NVS data based on
what cfg80211 says.  In all cases, cfg80211 drives the regulatory domain
[1].

a) How many regulatory domains does the driver support, how much data is
there for each domain, and can that be put into the driver instead of
getting it from the CAL partition?

b) what do *other* (non-N900) wl1251 devices do for regulatory data?

Dan

[1] unless there's some *restriction* hardcoded into the EEPROM of the
device, which in the case of the N900 there isn't, since the regulatory
data changes based on the MCC/MNC of the cellular side.
