From: Bart Van Assche <bvanassche@acm.org>
Subject: Re: [RFC PATCH 1/5] libfcoe, fcoe: Allow user to set a ctlr's mode
Date: Tue, 11 Sep 2012 07:51:41 +0200
Message-ID: <504ED16D.5080607@acm.org>
References: <20120910225908.13140.97277.stgit@fritz> <20120910225914.13140.22190.stgit@fritz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gregkh@linuxfoundation.org,
	linux-scsi@vger.kernel.org, bprakash@broadcom.com,
	devel@open-fcoe.org
To: Robert Love <robert.w.love@intel.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20120910225914.13140.22190.stgit@fritz>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/11/12 00:59, Robert Love wrote:
> +static enum fip_conn_type fcoe_parse_mode(const char *buf,
> +				  const struct fcoe_ctlr_mode_table *tbl)
> +{
> +	int modeint = -1, i, rv;
> +	char *p, modestr[FCOE_MAX_MODENAME_LEN + 1] = { 0, };
> +
> +	for (p = (char *)buf; *p; p++)
> +		if (!(isdigit(*p) || isspace(*p)))
> +			break;

If you change the declaration of p from "char *p" into "const char *p"
you won't need a cast in the above for loop.

[ ... ]

> -static FCOE_DEVICE_ATTR(ctlr, mode, S_IRUGO,
> -			show_ctlr_mode, NULL);
> +
> +static ssize_t store_ctlr_mode(struct device *dev,
> +			       struct device_attribute *attr,
> +			       const char *buf, size_t count)
> +{
> +	struct fcoe_ctlr_device *ctlr = dev_to_ctlr(dev);
> +
> +	if (!ctlr->f->set_fcoe_ctlr_mode)
> +		return -EINVAL;
> +
> +	ctlr->mode = fcoe_parse_mode(buf, ctlr_mode_tbl);

As far as I know sysfs doesn't terminate buf with a '\0' before calling
a store method. Does that mean that you are passing a string that is not
'\0'-terminated to a function that expects a '\0'-terminated string ?

Bart.
