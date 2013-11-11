From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH] usbnet: fix race condition caused spinlock bad magic
 issue
Date: Mon, 11 Nov 2013 08:44:23 +0100
Message-ID: <1384155863.23930.4.camel@linux-fkkt.site>
References: <1384139315.2179.9.camel@wangbiao>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	mingo@elte.hu, a.p.zijlstra@chello.nl, rusty@rustcorp.com.au,
	william.douglas@intel.com
To: wangbiao <biao.wang@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1384139315.2179.9.camel@wangbiao>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-11-11 at 11:08 +0800, wangbiao wrote:
> From: wang, biao <biao.wang@intel.com>
> Date: Mon, 11 Nov 2013 10:23:40 +0800
> Subject: [PATCH] usbnet: fix race condition caused spinlock bad magic issue
> 
> there is race between usbnet_terminate_urbs and usbnet_bh, when
> unlink_wakeup used in usbnet_bh, it may be already freed and used by
> other function as unlink_wakeup was a local var on stack.

Hi,

the debugging is good, but the fix is not good.

If you use a global variable, you can init the head
only once, that is on module load, not during probe()
Doing so can mess up operations with multiple modules
as a hotplug happens.

	Regards
		Oliver
