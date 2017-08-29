From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] staging: irda: force to be a kernel module
Date: Tue, 29 Aug 2017 10:40:02 -0700 (PDT)
Message-ID: <20170829.104002.1846880154337344552.davem@davemloft.net>
References: <20170829091417.GA9481@kroah.com>
        <20170829.093507.2166038228205751885.davem@davemloft.net>
        <20170829172608.GA4700@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170829172608.GA4700@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Greg KH <gregkh@linuxfoundation.org>
Date: Tue, 29 Aug 2017 19:26:08 +0200

> On Tue, Aug 29, 2017 at 09:35:07AM -0700, David Miller wrote:
>> From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>> Date: Tue, 29 Aug 2017 11:14:17 +0200
>> 
>> > Now that the IRDA networking code has moved into drivers/staging/, the
>> > link order is changed for when it is initialized if built into the
>> > system.  This can cause a crash when initializing as the netfilter core
>> > hasn't been initialized yet.
>> > 
>> > So force the IRDA code to be built as a module, preventing the crash.
>> > 
>> > Reported-by: kernel test robot <fengguang.wu@intel.com>
>> > Signed-off-by: Greg Kroah-Hartman gregkh@linuxfoundation.org
>> 
>> I don't think this is reasonable.
>> 
>> IRDA being built in was broken by moving it to staging, so it's a
>> regression and we should find a way to fix it.
> 
> Hm, this is due to netlink coming before irda in the link order before
> this patch series.  I can't change the link order to put all of net/
> before drivers/, which would solve this, and I don't think I can put:
> 	obj-$(CONFIG_IRDA) += ../../drivers/staging/irda/net/
> in a networking Makefile, can I?  Does "../" even work in a Makefile
> like that?
> 
> Any other thoughts?

Change the initialization type in IRDA from subsys_init() to ...
something else?

Amazing!
