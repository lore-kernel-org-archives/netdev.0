From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 4/5] ieee802154: add virtual loopback driver
Date: Thu, 18 Jun 2009 18:14:38 +0200
Message-ID: <4A3A67EE.3000809@trash.net>
References: <1245335177-16810-1-git-send-email-dbaryshkov@gmail.com> <1245335177-16810-2-git-send-email-dbaryshkov@gmail.com> <1245335177-16810-3-git-send-email-dbaryshkov@gmail.com> <1245335177-16810-4-git-send-email-dbaryshkov@gmail.com> <1245335177-16810-5-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sergey Lapin <slapin@ossfans.org>
To: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34889 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752634AbZFRQOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 12:14:36 -0400
In-Reply-To: <1245335177-16810-5-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dmitry Eremin-Solenikov wrote:
> fakelb is a virtual loopback driver implementing one or several
> interconnected radios. Packets from the radio are either sent
> back to the node (if no other fake radio are registered) or to
> all other fake radio.
> 
> +static ssize_t
> +adddev_store(struct device *dev, struct device_attribute *attr,
> +	const char *buf, size_t n)
> +{
> +	struct platform_device *pdev = to_platform_device(dev);
> +	struct fake_priv *priv = platform_get_drvdata(pdev);
> +	char hw[8] = {};
> +	int i, j, ch, err;
> +
> +	for (i = 0, j = 0; i < 16 && j < n; j++) {
> +		ch = buf[j];
> +		switch (buf[j]) {
> +		default:
> +			return -EINVAL;
> +		case '0'...'9':
> +			ch -= '0';
> +			break;
> +		case 'A'...'F':
> +			ch -= 'A' - 10;
> +			break;
> +		case 'a'...'f':
> +			ch -= 'a' - 10;
> +			break;
> +		case ':':
> +		case '.':
> +			continue;
> +		}
> +		if (i % 2)
> +			hw[i/2] = (hw[i/2] & 0xf0) | ch;
> +		else
> +			hw[i/2] = ch << 4;
> +		i++;
> +	}
> +	if (i != 16)
> +		return -EINVAL;
> +	err = ieee802154fake_add_priv(dev, priv, hw);
> +	if (err)
> +		return err;
> +	return n;
> +}
> +
> +static DEVICE_ATTR(adddev, 0200, NULL, adddev_store);
> +
> +static struct attribute *fake_attrs[] = {
> +	&dev_attr_adddev.attr,
> +	NULL,
> +};


No new sysfs interfaces for network device creation please.
Please use the rtnl_link API.
