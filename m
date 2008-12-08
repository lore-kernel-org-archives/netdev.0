From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [PATCH 07/29] wimax: basic API: kernel/user messaging, rfkill and reset
Date: Mon, 8 Dec 2008 13:24:17 -0800
Message-ID: <200812081324.17703.inaky@linux.intel.com>
References: <cover.1228759689.git.inaky@linux.intel.com> <e4e92ac65c4617b40d8ed79c416392cde7e51534.1228759689.git.inaky@linux.intel.com> <1228766499.22164.123.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wimax@linuxwimax.org, greg@kroah.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:62778 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752225AbYLHVYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 16:24:21 -0500
In-Reply-To: <1228766499.22164.123.camel@johannes.berg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 08 December 2008, Johannes Berg wrote:
> On Mon, 2008-12-08 at 11:09 -0800, Inaky Perez-Gonzalez wrote:
 >
> > +struct sk_buff *wimax_pipe_msg_alloc(struct wimax_dev *wimax_dev,
> > +				     const void *msg, size_t size,
> > +				     gfp_t gfp_flags)
...
> > +	might_sleep();
> > +	d_fnstart(3, NULL, "(skb %p info %p)\n", skb, info);
> > +	result = -EPERM;
> > +	if (security_netlink_recv(skb, CAP_NET_ADMIN))
> > +		goto error_perm;
>
> perms check?

Ouch, sorry, right; wonder how I missed this one.

>
> > +	result = -ENODEV;
> > +	wimax_dev = wimax_dev_get_by_genl_info(info);
> > +	if (wimax_dev == NULL)
> > +		goto error_no_wimax_dev;
> >
> >
> > +	result = wimax_dev->op_msg_from_user(wimax_dev, msg_buf, msg_len,
> > info); +error_noop:
> > +error_not_ready:
> > +	mutex_unlock(&wimax_dev->mutex);
> > +error_no_data:
> > +	dev_put(wimax_dev->net_dev);
> > +error_no_wimax_dev:
> > +error_perm:
> > +	d_fnend(3, NULL, "(skb %p info %p) = %d\n", skb, info, result);
> > +	return result;
>
> Do you really need all the fnstart/fnend debugging everywhere? Isn't
> this easily covered by ftrace nowadays? If you remove that you can very
> much simplify the code by using "return -ESOMETHING" instead of jumping
> to a label in many of these functions.

ftrace: ack -- just let it stabilize a couple of versions (/me thinks e1000
fiasco), then I'll happily get rid of them.

-- 
Inaky
