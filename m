From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: New commands to configure IOV features
Date: Thu, 20 Sep 2012 02:23:10 +0100
Message-ID: <1348104190.4836.61.camel@deadeye.wl.decadent.org.uk>
References: <5003DC9B.8000706@broadcom.com> <5005BD00.4090106@redhat.com>
	 <5005D45D.1040302@genband.com>
	 <20120717.141153.46613285253481776.davem@davemloft.net>
	 <500978C7.5050004@genband.com> <50097FBD.9080202@redhat.com>
	 <1342806146.2678.31.camel@bwh-desktop.uk.solarflarecom.com>
	 <5009B186.6000806@genband.com>
	 <1342814473.2678.65.camel@bwh-desktop.uk.solarflarecom.com>
	 <5009ECDF.4090305@genband.com> <500D59BF.9040006@redhat.com>
	 <500D6932.8090306@genband.com>
	 <20120723113607.56ce7aaf@nehalam.linuxnetplumber.net>
	 <C5551D9AAB213A418B7FD5E4A6F30A070C7D9DCD@ORSMSX106.amr.corp.intel.com>
	 <5059A767.2090307@broadcom.com> <20120919085306.00006af9@unknown>
	 <1348083847.2636.37.camel@bwh-desktop.uk.solarflarecom.com>
	 <CAE9FiQXQj_KdWT-mVVsptxiEgGjScgDy_Lp-aXioZ4YAQh1wWQ@mail.gmail.com>
	 <1348094773.2636.85.camel@bwh-desktop.uk.solarflarecom.com>
	 <CAE9FiQVk-uXgLK6dM8q5-Xsh8LO+c-Dd_cEpu2WzJ6Uzt6ztnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Bjorn Helgaas <bhelgaas@google.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Yuval Mintz <yuvalmin@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ariel Elior <ariele@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	linux-pci <linux-pci@vger.kernel.org>
To: Yinghai Lu <yinghai@kernel.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <CAE9FiQVk-uXgLK6dM8q5-Xsh8LO+c-Dd_cEpu2WzJ6Uzt6ztnA@mail.gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-09-19 at 17:19 -0700, Yinghai Lu wrote:
> On Wed, Sep 19, 2012 at 3:46 PM, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
> > On Wed, 2012-09-19 at 15:17 -0700, Yinghai Lu wrote:
> >> +max_vfs_store(struct device *dev, struct device_attribute *attr,
> >> +                const char *buf, size_t count)
> >> +{
> >> +       unsigned long val;
> >> +       struct pci_dev *pdev = to_pci_dev(dev);
> >> +
> >> +       if (strict_strtoul(buf, 0, &val) < 0)
> >> +               return -EINVAL;
> >> +
> >> +       pdev->max_vfs = val;
> >> +
> >> +       return count;
> >> +}
> > [...]
> >
> > Then what would actually trigger creation of the VFs?  There's no way we
> > can assume that some sysfs attribute will be written before the PF
> > driver is loaded (what if it's built-in?).  I thought the idea was to
> > add a driver callback that would be called when the sysfs attribute was
> > written.
> 
> could just stop the device and add it back again?

This is highly disruptive and I think it would be totally unacceptable
for at least networking devices.

Ben.

> just like updated patch.
> 
> Thanks
> 
> Yinghai

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
