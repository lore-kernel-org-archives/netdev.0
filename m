From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH 19/39] i2400m: sysfs controls
Date: Thu, 27 Nov 2008 01:07:41 +0300
Message-ID: <20081126220741.GA19779@ioremap.net>
References: <cover.1227562829.git.inaky@linux.intel.com> <50c439125339069856c5ba57c817de253ba99bb3.1227562829.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cet.com.ru ([195.178.208.66]:60871 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750911AbYKZWHq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Nov 2008 17:07:46 -0500
Content-Disposition: inline
In-Reply-To: <50c439125339069856c5ba57c817de253ba99bb3.1227562829.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

Spotted an issue.

On Mon, Nov 24, 2008 at 01:50:42PM -0800, Inaky Perez-Gonzalez (inaky@linux.intel.com) wrote:
> +static
> +ssize_t i2400m_reset_cold_store(struct device *dev,
> +				struct device_attribute *attr,
> +				const char *buf, size_t size)
> +{
> +	ssize_t result;
> +	struct i2400m *i2400m = net_dev_to_i2400m(to_net_dev(dev));
> +	unsigned val;
> +
> +	result = -EINVAL;
> +	if (sscanf(buf, "%u\n", &val) != 1)
> +		goto error_no_unsigned;
> +	if (val != 1)
> +		goto error_bad_value;
> +	i2400m_schedule_work(i2400m, __i2400m_reset_cold_work, GFP_KERNEL);
> +	if (result >= 1)
> +		result = size;

This never executes since result is always -EINVAL, isn't it?

> +error_no_unsigned:
> +error_bad_value:
> +	return result;
> +}
> +

-- 
	Evgeniy Polyakov
