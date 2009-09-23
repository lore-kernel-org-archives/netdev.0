From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [PATCH 1/3] iwmc3200top: Add Intel Wireless MultiCom 3200 top
 driver.
Date: Wed, 23 Sep 2009 10:48:14 -0700
Message-ID: <1253728094.3033.240.camel@localhost.localdomain>
References: <1253662724-16497-1-git-send-email-tomas.winkler@intel.com>
	 <1253662724-16497-2-git-send-email-tomas.winkler@intel.com>
	 <1253689036.4458.22.camel@johannes.local>
	 <1ba2fa240909230023v17fe2b49v4981d464dba469ed@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>,
	"Zhu, Yi" <yi.zhu@intel.com>,
	"Kao, Cindy H" <cindy.h.kao@intel.com>,
	"Cohen, Guy" <guy.cohen@intel.com>,
	"Rindjunsky, Ron" <ron.rindjunsky@intel.com>
To: Tomas Winkler <tomasw@gmail.com>
Return-path: <linux-mmc-owner@vger.kernel.org>
In-Reply-To: <1ba2fa240909230023v17fe2b49v4981d464dba469ed@mail.gmail.com>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-09-23 at 01:23 -0600, Tomas Winkler wrote:
> On Wed, Sep 23, 2009 at 9:57 AM, Johannes Berg
> <johannes@sipsolutions.net> wrote:
> > On Wed, 2009-09-23 at 02:38 +0300, Tomas Winkler wrote:
> >
> >> +config IWMC3200TOP
> >> +        tristate "Intel Wireless MultiCom Top Driver"
> >> +        depends on MMC && EXPERIMENTAL
> >> +        select FW_LOADER
> >> +     ---help---
> >> +       Intel Wireless MultiCom 3200 Top driver is responsible for
> >> +       for firmware load and enabled coms enumeration
> >
> > This seems like the wrong approach to me.
> >
> > To me, it seems like you have a device that contains an internal bus and
> > allows bus enumeration. Typically, we would surface that bus in the
> > driver/device model and allow sub-drivers to bind to that by way of
> > exposing the internal bus, like e.g. drivers/ssb/.
> 
> From HW perspective your assumption is not exactly correct. All the
> devices are visible on the SDIO bus but they are not operational
> (probe won't succeed) until TOP download the firmware and kicks the
> devices. From SW perspective to create another bus layer is an option.
> I'm not sure if it's not more complicated one.

It is definitely more complicated; we thought about it and it wasn't
worth. The current solution works and it is simple enough.

To extend Tomas' explanation:

1 device powers up
2 enabling any sdio function that is not the top one fails; drivers
  return -ENODEV
3 top function is enabled, firmware loaded, it initializes
  the rest of the functions. Top driver kicks a SDIO bus rescan
  on a workqueue
4 other sdio functions can be enabled and probe succesfully (uploading
  firmware, yadah yadah).

A subbus would add a lot of complexity to all this, having to replicate
most of the device probing, suspend/resume, pre/post reset (that's is 
being added to SDIO).

Thanks,



