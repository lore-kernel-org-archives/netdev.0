From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] RFC: ipv4: share sysctl net/ipv4/conf/DEVNAME/ tables
Date: Sat, 15 Jan 2011 12:41:39 +0200
Message-ID: <20110115104139.GA4816@p183.telecom.by>
References: <AANLkTikVDn_0c+Ob_XnUauEMBZhsYCh+42QF7FwM=Bey@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Nick Piggin <npiggin@kernel.dk>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Christoph Hellwig <hch@lst.de>,
	Dave Chinner <dchinner@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Octavian Purdila <opurdila@ixiacom.com>,
	Vlad Dogaru <ddvlad@rosedu.org>
To: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:42469 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751853Ab1AOKr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Jan 2011 05:47:59 -0500
Received: by ewy5 with SMTP id 5so1946992ewy.19
        for <netdev@vger.kernel.org>; Sat, 15 Jan 2011 02:47:57 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <AANLkTikVDn_0c+Ob_XnUauEMBZhsYCh+42QF7FwM=Bey@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 15, 2011 at 04:46:11AM +0200, Lucian Adrian Grijincu wrote:
> To gain access to the name of the directory above a file, sysctl
> handlers are passed an extra argument: the 'struct file*'
> corresponding to the file. From the file we walk up one level to find
> the name of the device. None of the other handlers were changed to
> receive this extra parameter, but due to C's calling convention they
> shouldn't care.

We don't do creepy stuff like that.

I wonder where interactions with device renaming are handled.

> +static int devinet_conf_handler(ctl_table *ctl, int write,
> +				void __user *buffer,
> +				size_t *lenp, loff_t *ppos,
> +				struct file *filp,
> +				proc_handler *proc_handler)
> +{
> +	/* The path to this file is of the form /proc/sys/net/ipv4/conf/$DEVNAME/$CTL
> +	 *
> +	 * To save space, ctl_table is shared between all network
> +	 * devices in the same network namespace, but we need to
> +	 * change the data corresponding to the $DEVNAME network
> +	 * device, not any other's.
> +	 *
> +	 * Use $DEVNAME to obtain the coresponding ipv4_devconf.
> +	 */
> +	struct net *net = ctl->extra2;
> +	const char *dev_name = filp->f_path.dentry->d_parent->d_name.name;
