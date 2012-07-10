From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net,1/1] hyperv: Add support for setting MAC from within
 guests
Date: Tue, 10 Jul 2012 17:03:53 +0000
Message-ID: <A1F3067C9B68744AA19F6802BAB8FFDC0DDC8C5E@TK5EX14MBXC222.redmond.corp.microsoft.com>
References: <1341609932-18971-1-git-send-email-haiyangz@microsoft.com>
 <1341620355.2923.46.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <1341620355.2923.46.camel@bwh-desktop.uk.solarflarecom.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Ben Hutchings [mailto:bhutchings@solarflare.com]
> Sent: Friday, July 06, 2012 8:19 PM
> To: Haiyang Zhang
> Cc: davem@davemloft.net; netdev@vger.kernel.org; KY Srinivasan;
> olaf@aepfle.de; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org
> Subject: Re: [PATCH net,1/1] hyperv: Add support for setting MAC from
> within guests
> 
> On Fri, 2012-07-06 at 14:25 -0700, Haiyang Zhang wrote:
> > This adds support for setting synthetic NIC MAC address from within
> Linux
> > guests. Before using this feature, the option "spoofing of MAC
> address"
> > should be enabled at the Hyper-V manager / Settings of the synthetic
> > NIC.
> [...]
> > +int rndis_filter_set_device_mac(struct hv_device *hdev, char *mac)
> > +{
> [...]
> > +	t = wait_for_completion_timeout(&request->wait_event, 5*HZ);
> > +	if (t == 0) {
> > +		netdev_err(ndev, "timeout before we got a set
> response...\n");
> > +		/*
> > +		 * can't put_rndis_request, since we may still receive a
> > +		 * send-completion.
> > +		 */
> > +		return -EBUSY;
> > +	} else {
> > +		set_complete = &request->response_msg.msg.set_complete;
> > +		if (set_complete->status != RNDIS_STATUS_SUCCESS)
> > +			ret = -EINVAL;
> [...]
> 
> Is there a specific error code that indicates the hypervisor is
> configured not to allow MAC address changes?  If so, shouldn't that be
> translated to return EPERM rather than EINVAL?

I have check the return code, 0xc000000d, which is returned both when MAC
spoofing is not enabled or the parameter contains other errors. So we can't
tell if it permission error or not. I will re-submit this patch still
using EINVAL.

Thanks,
- Haiyang
