From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [PATCH 19/39] i2400m: sysfs controls
Date: Wed, 26 Nov 2008 14:25:03 -0800
Message-ID: <200811261425.04052.inaky@linux.intel.com>
References: <cover.1227562829.git.inaky@linux.intel.com> <50c439125339069856c5ba57c817de253ba99bb3.1227562829.git.inaky@linux.intel.com> <20081126220741.GA19779@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:36364 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752234AbYKZWZZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Nov 2008 17:25:25 -0500
In-Reply-To: <20081126220741.GA19779@ioremap.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 26 November 2008, Evgeniy Polyakov wrote:
> Hi.
>
> Spotted an issue.
>
> On Mon, Nov 24, 2008 at 01:50:42PM -0800, Inaky Perez-Gonzalez 
(inaky@linux.intel.com) wrote:
> > +static
> > +ssize_t i2400m_reset_cold_store(struct device *dev,
> > +				struct device_attribute *attr,
> > +				const char *buf, size_t size)
> > +{
> > +	ssize_t result;
> > +	struct i2400m *i2400m = net_dev_to_i2400m(to_net_dev(dev));
> > +	unsigned val;
> > +
> > +	result = -EINVAL;
> > +	if (sscanf(buf, "%u\n", &val) != 1)
> > +		goto error_no_unsigned;
> > +	if (val != 1)
> > +		goto error_bad_value;
> > +	i2400m_schedule_work(i2400m, __i2400m_reset_cold_work, GFP_KERNEL);
> > +	if (result >= 1)
> > +		result = size;
>
> This never executes since result is always -EINVAL, isn't it?

Right -- the thing is scheduled by to the user it always returns -EINVAl.
Good catch, thanks -- fixing it.



-- 
Inaky
