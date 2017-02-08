From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 1/9] sunvnet: make sunvnet common code
 dynamically loadable
Date: Wed, 08 Feb 2017 14:29:18 -0500 (EST)
Message-ID: <20170208.142918.491209108288972402.davem@davemloft.net>
References: <1486505582-76823-1-git-send-email-shannon.nelson@oracle.com>
        <1486505582-76823-2-git-send-email-shannon.nelson@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sparclinux@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: shannon.nelson@oracle.com
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <1486505582-76823-2-git-send-email-shannon.nelson@oracle.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shannon Nelson <shannon.nelson@oracle.com>
Date: Tue,  7 Feb 2017 14:12:54 -0800

> +static int __init sunvnet_common_init(void)
> +{
> +	pr_info("%s\n", version);
> +	return 0;
> +}
> +module_init(sunvnet_common_init);
> +
> +static void __exit sunvnet_common_exit(void)
> +{
> +	/* Empty function, just here to fill the exit function pointer
> +	 * slot.  In some combinations of older gcc and newer kernel,
> +	 * leaving this undefined results in the kernel marking it as a
> +	 * permanent module; it will show up in lsmod output as [permanent]
> +	 * and not be unloadable.
> +	 */
> +}
> +module_exit(sunvnet_common_exit);
> +

This module is just providing infrastructure for other modules.

So skip the init function, and that way you don't need the exit
function either.

The kernel log message when the real sunvnet driver loads is
sufficient, you don't need one here.
