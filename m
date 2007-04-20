From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH -mm take4 3/6] add interface for netconsole using
 sysfs
Date: Thu, 19 Apr 2007 21:06:16 -0700
Message-ID: <20070419210616.8012fc59.akpm@linux-foundation.org>
References: <462605DC.2080804@bx.jp.nec.com>
	<46260A4D.1050005@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Keiichi KII <k-keiichi@bx.jp.nec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:51108 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753868AbXDTEGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 00:06:34 -0400
In-Reply-To: <46260A4D.1050005@bx.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 18 Apr 2007 21:08:45 +0900 Keiichi KII <k-keiichi@bx.jp.nec.com> wrote:

> +static ssize_t store_local_port(struct netconsole_target *nt, const char *buf,
> +				size_t count)
> +{
> +	spin_lock(&target_list_lock);
> +	nt->np.local_port = simple_strtol(buf, NULL, 10);
> +	spin_unlock(&target_list_lock);
> +
> +	return count;
> +}
> +
> +static ssize_t store_remote_port(struct netconsole_target *nt, const char *buf,
> +				size_t count)
> +{
> +	spin_lock(&target_list_lock);
> +	nt->np.remote_port = simple_strtol(buf, NULL, 10);
> +	spin_unlock(&target_list_lock);
> +
> +	return count;
> +}

I think that you'll find that the locking in here does nothing useful and
can be removed.


Also, write_msg() can be called from IRQ context, so this lock _must_ be
taken with spin_lock_irq[save] basically everywhere - the code as-is can be
deadlocked.


