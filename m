From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 20/21] ntb_netdev: improve logging
Date: Sat, 19 Jan 2013 10:51:02 -0800
Message-ID: <1358621462.2108.3.camel@joe-AO722>
References: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
	 <1358586155-23322-21-git-send-email-jon.mason@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Greg KH <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: Jon Mason <jon.mason@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358586155-23322-21-git-send-email-jon.mason@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2013-01-19 at 02:02 -0700, Jon Mason wrote:
> Improve driver logging to be more helpful
[]
> diff --git a/drivers/net/ntb_netdev.c b/drivers/net/ntb_netdev.c
[]
> @@ -408,6 +408,5 @@ static void __exit ntb_netdev_exit_module(void)
>  {
>  	ntb_unregister_client(&ntb_netdev_client);
>  	ntb_unregister_client_dev(KBUILD_MODNAME);
> -	pr_info("%s: Driver removed\n", KBUILD_MODNAME);

It's almost always true that using
#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
before any #include

and changing all pr_<level>( uses from

	pr_<level>("s: etc...", KBUiLD_MODNAME, ...)
to
	pr_<level>("etc...", ...)

produces overall smaller object code.
That's even more likely for 64 bit compiled code.
