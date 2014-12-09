From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: wl1251: NVS firmware data
Date: Tue, 9 Dec 2014 06:10:20 +0100
Message-ID: <2546C295-8A84-4399-B93D-CC65C812903C@holtmann.org>
References: <201411271506.20457@pali> <201412081811.46943@pali> <30072B9E-2495-4F90-AC91-9C0D7E08F44E@holtmann.org> <201412082015.18501@pali> <1418066813.1350.18.camel@dcbw.local> <5485FF17.1070504@gmail.com> <1418078493.31640.4.camel@dcbw.local>
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
	=?utf-8?Q?Pali_Roh=C3=A1r?= <pali.rohar@gmail.com>,
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
To: Dan Williams <dcbw@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1418078493.31640.4.camel@dcbw.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dan,

>>> a) change driver to prefer a new "wl1251-nvs-n900.bin" file, but fall
>>> back to "wl1251-nvs.bin" if the first one isn't present
>>> b) have a "wl1251-cal-nvs-update" service that, if wl1521-nvs-n900.bin
>>> is *not* present mounts the CAL MTD, reads the data, writes it out into
>>> wl1521-nvs-n900.bin, and the rmmod/modprobes the driver
>>> 
>>> and done?  Stuff that's not N900 just wouldn't ship the update service
>>> and would proceed like none of this happened.
>>> 
>>> Dan
>>> 
>>> 
>> 
>> That would mean that the driver should not be built-in, as afaik we 
>> cannot rmmod built-in drivers. Sure, it will work after a reboot, but 
>> this is a bit hacky, agree?
>> 
>> Also, new NVS file needs to be loaded when fcc regulation changes(flying 
>> abroad), so that would mean that the device would be outside of those 
>> until reboot (in case of built-in driver)
> 
> Regulatory stuff needs to be hooked into CRDA or the existing regulatory
> codepaths, not some other path.  So when cfg80211 sets the regulatory
> domain on the driver the driver needs to get the necessary NVS data.
> Either the NVS for every domain (which cannot be a lot of them) gets
> hardcoded into the driver, and then selected based on what cfg80211
> says, or the driver needs to ask userspace for the NVS data based on
> what cfg80211 says.  In all cases, cfg80211 drives the regulatory domain
> [1].
> 
> a) How many regulatory domains does the driver support, how much data is
> there for each domain, and can that be put into the driver instead of
> getting it from the CAL partition?
> 
> b) what do *other* (non-N900) wl1251 devices do for regulatory data?
> 
> Dan
> 
> [1] unless there's some *restriction* hardcoded into the EEPROM of the
> device, which in the case of the N900 there isn't, since the regulatory
> data changes based on the MCC/MNC of the cellular side.

and even these ones would all work just fine. The regulatory handling of cfg80211 is already multi-layer anyway. I will intersect from the driver provided information and userspace provided information.

I mean if userspace can just make up some NVS data to change the regulatory enforcement or let cfg80211 do it for you, there is no difference. So the real question is why bother with this at all in the first place. We already have a solution that does exactly what you want. Use CRDA and be done with it.

And calibration data should be rather static for each device. It might differ from device a to device b, but on device a it would stay the same. These calibration data are normally programmed at the factory line and then never changed again.

For me this sounds all a bit like that everybody is buying into this NVS file solution for everything and now trying to hack that into something workable. But nobody actually looks at the existing solutions out there and really tries to fix the mess that Nokia and TI left behind for this chipset.

Regards

Marcel
