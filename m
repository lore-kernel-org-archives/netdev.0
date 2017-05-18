From: Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 2/6] wl1251: Use request_firmware_prefer_user() for
 loading NVS calibration data
Date: Wed, 17 May 2017 17:08:49 -0700
Message-ID: <20170518000848.GK12920@tuxbook>
References: <0fd90416-f33c-a6be-14fd-5e964583e9cb@broadcom.com>
 <20170515231339.GF17314@wotan.suse.de>
 <1495022766.2442.1.camel@sipsolutions.net>
 <20170517125335.GG10015@pali>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
        "Luis R. Rodriguez" <mcgrof-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Arend Van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>, Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>,
        Tom Gundersen <teg-B22kvLQNl6c@public.gmane.org>,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        David Gnedt <david.gnedt-rFfgOQFw6VLk7+2FdBfRIA@public.gmane.org>,
        Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>,
        Sebastian Reichel <sre-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Aaro Koskinen <aaro.koskinen-X3B1VOXEql0@public.gmane.org>,
        Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>,
        AKASHI Takahiro <takahiro.akashi-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
        Grazvydas Ignotas <notasas-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Micha?? Kazior <kaz
To: Pali Roh?r <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170517125335.GG10015@pali>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed 17 May 05:53 PDT 2017, Pali Roh?r wrote:

> On Wednesday 17 May 2017 14:06:06 Johannes Berg wrote:
> > On Tue, 2017-05-16 at 01:13 +0200, Luis R. Rodriguez wrote:
> > > > > Now for N900 case there is a similar scenario
> > > > > alhtough it has additional requirement to go to user-space due to
> > > > > need to use a proprietary library to obtain the NVS calibration
> > > > > data. My thought: Why should firmware_class care?
> > > 
> > > Agreed.
> > 
> > In fact, why should the *driver* care either? IOW - why should
> > "request_firmware_prefer_user()" even exist?
> 
> There are default/example NVS data, which are stored in /lib/firmware
> and installed by linux-firmware package. Those example calibration data
> should not be used for real usage, but Pavel told us that on N900 they
> are enough for working WIFI connection. They does not contain valid MAC
> address, so kernel should generate some (random?).
> 
> So kernel driver should get NVS calibration data from userspace (which
> know how where to get or how to prepare them) and in case userspace do
> not have it, then we can try fallback to those example data (as people
> reported us they can be useful instead of non-working WIFI).
> 

We're going to see a similar case with the Qualcomm DB410c WiFi soon,
where there is default calibration for the chip (wcn3620) but specific
calibration data for the particular board or product using this chip.

As with your case we expect to have a "generic" calibration file
integrated in linux-firmware, but providing means to supporting
device-specific calibration is probably going to be requested shortly.


We have however altered the reference design of picking the MAC address
from the calibration data and have the bootloader pass it via DT - so
our calibration data doesn't need to be specific to each unit.

Regards,
Bjorn
