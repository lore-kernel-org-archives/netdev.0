From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: Re: [PATCH 2/6] wl1251: Use request_firmware_prefer_user() for
 loading NVS calibration data
Date: Thu, 10 Aug 2017 21:43:01 +0200
Message-ID: <20170810194301.GV27873@wotan.suse.de>
References: <0fd90416-f33c-a6be-14fd-5e964583e9cb@broadcom.com>
 <20170515231339.GF17314@wotan.suse.de>
 <0c43c825-df2a-b427-4b67-f17fd644667f@broadcom.com>
 <20170623215319.GU21846@wotan.suse.de>
 <a956b366-95d9-e876-4dba-149d2987633a@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>, Li@suse.de,
        Yi <yi1.li@linux.intel.com>,
        Johannes Berg <johannes@sipsolutions.net>,
        Pavel Machek <pavel@ucw.cz>, Daniel Wagner <wagi@monom.org>,
        Tom Gundersen <teg@jklm.no>,
        Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Kalle Valo <kvalo@codeaurora.org>,
        David Gnedt <david.gnedt@davizone.at>,
        Tony Lindgren <tony@atomide.com>,
        Sebastian Reichel <sre@kernel.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Takashi Iwai <tiwai@suse.de>,
        AKASHI Takahiro <takahiro.akashi@linaro.org>,
        David Woodhouse <dwmw2@infradead.org>,
        Bjorn Andersson <bjorn.andersson@linaro.org>,
        Grazvydas Ignotas <notasas@gmail.com>,
        linux
To: Arend van Spriel <arend.vanspriel@broadcom.com>,
        Lennart Poettering <lennart@poettering.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <a956b366-95d9-e876-4dba-149d2987633a@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 30, 2017 at 11:35:41PM +0200, Arend van Spriel wrote:
> On 23-06-17 23:53, Luis R. Rodriguez wrote:
> > On Tue, May 16, 2017 at 10:41:08AM +0200, Arend Van Spriel wrote:
> >> On 16-5-2017 1:13, Luis R. Rodriguez wrote:
> >>> Since no upstream delta is needed for firmwared I'd like to first encourage
> >>> evaluating the above. While distributions don't carry it yet that may be seen as
> >>> an issue but since what we are looking for are corner cases, only folks needing
> >>> to deploy a specific solution would need it or a custom proprietary solution.
> >>
> >> Ok. I will go try and run firmwared in OpenWrt on a router platform.
> >> Have to steal one from a colleague :-p Will study firmwared.
> > 
> > Arend, curious how this effort goes. Its important to me as we know then that
> > if this works its a good approach to recommend moving forward which should also
> > prove less complex than that soup we had with the custom fallback stuff.
> 
> Hi Luis,
> 
> So I looked at firmwared and we basically need to extend it.

And actually as me and Johannes spoke long ago at Plumbers, its rather
expected folks would need this or just fork it off completely. firmwared
would just be a reference codebase on how to do these custom loaders.

*How regular* Linux distributions embrace this is still up in the air then,
because as Lennart has pointed out there is no plan to merge firmwared
to systemd.

*If* this is a requirement only for non-upstream drivers or patches on
which will not be merged upstream then this will work long term. If you
need regular distros to do something custom then their respective upstream
tools would need to be evaluated for how something similar would be done.

As far as I can tell perhaps the remote-proc thing would count as one
possible use-case for upstream drivers -- but even then the systems
that use it seem likely to use Android and then some custom userspace.

> For our
> router platform we need to obtain nvram calibration data from an MTD
> partition which contains the raw data, ie. no file-system on it. So
> firmwared would need some sort of configuration to map a particular
> firmware file to some action obtaining the data like kicking off some
> mtd-utils in my case.

I see. So platform specific.

Thanks for the update!
 
 Luis
