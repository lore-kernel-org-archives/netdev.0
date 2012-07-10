From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [PATCH net,1/1] hyperv: Add support for setting MAC from within
 guests
Date: Tue, 10 Jul 2012 18:23:09 +0100
Message-ID: <1341940989.2605.17.camel@bwh-desktop.uk.solarflarecom.com>
References: <1341609932-18971-1-git-send-email-haiyangz@microsoft.com>
	 <1341620355.2923.46.camel@bwh-desktop.uk.solarflarecom.com>
	 <A1F3067C9B68744AA19F6802BAB8FFDC0DDC8C5E@TK5EX14MBXC222.redmond.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <A1F3067C9B68744AA19F6802BAB8FFDC0DDC8C5E@TK5EX14MBXC222.redmond.corp.microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-07-10 at 17:03 +0000, Haiyang Zhang wrote:
> 
> > -----Original Message-----
> > From: Ben Hutchings [mailto:bhutchings@solarflare.com]
> > Sent: Friday, July 06, 2012 8:19 PM
> > To: Haiyang Zhang
> > Cc: davem@davemloft.net; netdev@vger.kernel.org; KY Srinivasan;
> > olaf@aepfle.de; linux-kernel@vger.kernel.org;
> > devel@linuxdriverproject.org
> > Subject: Re: [PATCH net,1/1] hyperv: Add support for setting MAC from
> > within guests
> > 
> > On Fri, 2012-07-06 at 14:25 -0700, Haiyang Zhang wrote:
> > > This adds support for setting synthetic NIC MAC address from within
> > Linux
> > > guests. Before using this feature, the option "spoofing of MAC
> > address"
> > > should be enabled at the Hyper-V manager / Settings of the synthetic
> > > NIC.
> > [...]
> > > +int rndis_filter_set_device_mac(struct hv_device *hdev, char *mac)
> > > +{
> > [...]
> > > +	t = wait_for_completion_timeout(&request->wait_event, 5*HZ);
> > > +	if (t == 0) {
> > > +		netdev_err(ndev, "timeout before we got a set
> > response...\n");
> > > +		/*
> > > +		 * can't put_rndis_request, since we may still receive a
> > > +		 * send-completion.
> > > +		 */
> > > +		return -EBUSY;
> > > +	} else {
> > > +		set_complete = &request->response_msg.msg.set_complete;
> > > +		if (set_complete->status != RNDIS_STATUS_SUCCESS)
> > > +			ret = -EINVAL;
> > [...]
> > 
> > Is there a specific error code that indicates the hypervisor is
> > configured not to allow MAC address changes?  If so, shouldn't that be
> > translated to return EPERM rather than EINVAL?
> 
> I have check the return code, 0xc000000d, which is returned both when MAC
> spoofing is not enabled or the parameter contains other errors. So we can't
> tell if it permission error or not. I will re-submit this patch still
> using EINVAL.

Oh well, thanks for trying!

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
