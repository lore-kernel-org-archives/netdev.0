From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 PATCH] ethtool: Support to take FW dump
Date: Wed, 04 May 2011 02:06:34 +0100
Message-ID: <1304471194.3203.5.camel@localhost>
References: <1304378957-24123-1-git-send-email-anirban.chakraborty@qlogic.com>
	 <1304378957-24123-2-git-send-email-anirban.chakraborty@qlogic.com>
	 <1304466797.2873.38.camel@bwh-desktop>
	 <2941C562-0D47-40DF-B2C0-6292381097AE@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:46484 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753768Ab1EDBGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2011 21:06:39 -0400
In-Reply-To: <2941C562-0D47-40DF-B2C0-6292381097AE@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-05-03 at 17:29 -0700, Anirban Chakraborty wrote:
> On May 3, 2011, at 4:53 PM, Ben Hutchings wrote:
> 
> > On Mon, 2011-05-02 at 16:29 -0700, anirban.chakraborty@qlogic.com wrote:
[...]
> >> +static int ethtool_get_dump_data(struct net_device *dev,
> >> +				void __user *useraddr)
> >> +{
> >> +	int ret;
> >> +	void *data;
> >> +	struct ethtool_dump dump;
> >> +	const struct ethtool_ops *ops = dev->ethtool_ops;
> >> +
> >> +	if (!dev->ethtool_ops->get_dump_data)
> >> +		return -EOPNOTSUPP;
> >> +
> >> +	if (copy_from_user(&dump, useraddr, sizeof(dump)))
> >> +		return -EFAULT;
> >> +	data = vzalloc(dump.len);
> > 
> > I think we ought to query the driver to find out the maximum dump
> > length, rather than using the length passed by the user (up to 4GB).  We
> > already check that the user has the CAP_NET_ADMIN capability but that
> > should not mean the ability to evade memory limits.
> That's right. The user makes a call to get_dump (ETHTOOL_GET_DUMP)
> first to get the size of the collected dump data for the current
> dump level (flag). Then it makes the call to get the dump data (ETHTOOL_GET_DUMP_DATA),
> as in above where it specifies the dump size.
> The patch ref-ed below demonstrated that.
> http://patchwork.ozlabs.org/patch/93729/  
[...]

I understand that the userland application will need to get the size
that way.  I'm saying that this code in the kernel should also get the
size from the driver, so that a malicious application cannot make the
kernel allocate an excessively large buffer.

Also, you'll need to submit your implementation along with this, as
David won't accept an extension to the API without a driver that
implements it.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

