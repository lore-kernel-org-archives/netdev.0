From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 7/8] net: Allow setting the network namespace by fd
Date: Thu, 23 Sep 2010 10:22:25 -0400
Message-ID: <4C9B62A1.7020606@hp.com>
References: <m1ocborgq7.fsf@fess.ebiederm.org> <m1hbhgq1v1.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	Ulrich Drepper <drepper@gmail.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	Pavel Emelyanov <xemul@parallels.com>,
	Ben Greear <greearb@candelatech.com>,
	Matt Helsley <matthltc@us.ibm.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Patrick McHardy <kaber@trash.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0186.atlanta.hp.com ([15.193.32.63]:37948 "EHLO
	g6t0186.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752798Ab0IWOWf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 10:22:35 -0400
In-Reply-To: <m1hbhgq1v1.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/23/2010 04:51 AM, Eric W. Biederman wrote:
> 
> Take advantage of the new abstraction and allow network devices
> to be placed in any network namespace that we have a fd to talk
> about.
> 
...
> +struct net *get_net_ns_by_fd(int fd)
> +{
> +	struct proc_inode *ei;
> +	struct file *file;
> +	struct net *net;
> +
> +	file = NULL;

No need to initialize this.

> +	net = ERR_PTR(-EINVAL);

or this?

> +	file = proc_ns_fget(fd);
> +	if (!fd)
> +		goto out;
> +		return ERR_PTR(-EINVAL);

Shouldn't this be:

	if (!file)

And the "goto" seems wrong, especially without a {} here.  Unless you
meant to keep the "goto" and branch below?

-Brian

> +
> +	ei = PROC_I(file->f_dentry->d_inode);
> +	if (ei->ns_ops != &netns_operations)
> +		goto out;
> +
> +	net = get_net(ei->ns);
> +out:
> +	if (file)
> +		fput(file);
> +	return net;
> +}
