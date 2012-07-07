From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net,1/1] hyperv: Add support for setting MAC from within
 guests
Date: Sat, 7 Jul 2012 01:19:15 +0100
Message-ID: <1341620355.2923.46.camel@bwh-desktop.uk.solarflarecom.com>
References: <1341609932-18971-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<kys@microsoft.com>, <olaf@aepfle.de>,
	<linux-kernel@vger.kernel.org>, <devel@linuxdriverproject.org>
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341609932-18971-1-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-07-06 at 14:25 -0700, Haiyang Zhang wrote:
> This adds support for setting synthetic NIC MAC address from within Linux
> guests. Before using this feature, the option "spoofing of MAC address"
> should be enabled at the Hyper-V manager / Settings of the synthetic
> NIC.
[...]
> +int rndis_filter_set_device_mac(struct hv_device *hdev, char *mac)
> +{
[...]
> +	t = wait_for_completion_timeout(&request->wait_event, 5*HZ);
> +	if (t == 0) {
> +		netdev_err(ndev, "timeout before we got a set response...\n");
> +		/*
> +		 * can't put_rndis_request, since we may still receive a
> +		 * send-completion.
> +		 */
> +		return -EBUSY;
> +	} else {
> +		set_complete = &request->response_msg.msg.set_complete;
> +		if (set_complete->status != RNDIS_STATUS_SUCCESS)
> +			ret = -EINVAL;
[...]

Is there a specific error code that indicates the hypervisor is
configured not to allow MAC address changes?  If so, shouldn't that be
translated to return EPERM rather than EINVAL?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
