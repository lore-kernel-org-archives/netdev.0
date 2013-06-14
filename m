From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netiucv: Hold rtnl between name allocation and device
 registration.
Date: Thu, 13 Jun 2013 17:41:54 -0700 (PDT)
Message-ID: <20130613.174154.4560842535243312.davem@davemloft.net>
References: <1371128987-3723-1-git-send-email-bpoirier@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-s390@vger.kernel.org, netdev@vger.kernel.org,
	ursula.braun@de.ibm.com, linux390@de.ibm.com,
	blaschka@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, cornelia.huck@de.ibm.com,
	linux-kernel@vger.kernel.org
To: bpoirier@suse.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371128987-3723-1-git-send-email-bpoirier@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Poirier <bpoirier@suse.de>
Date: Thu, 13 Jun 2013 09:09:47 -0400

> fixes a race condition between concurrent initializations of netiucv devices
> that try to use the same name.
> 
> sysfs: cannot create duplicate filename '/devices/iucv/netiucv2'
> [...]
> Call Trace:
> ([<00000000002edea4>] sysfs_add_one+0xb0/0xdc)
>  [<00000000002eecd4>] create_dir+0x80/0xfc
>  [<00000000002eee38>] sysfs_create_dir+0xe8/0x118
>  [<00000000003835a8>] kobject_add_internal+0x120/0x2d0
>  [<00000000003839d6>] kobject_add+0x62/0x9c
>  [<00000000003d9564>] device_add+0xcc/0x510
>  [<000003e00212c7b4>] netiucv_register_device+0xc0/0x1ec [netiucv]
> 
> Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
> Tested-by: Ursula Braun <braunu@de.ibm.com>

Yes as dev_alloc_name() must be invoked under RTNL or dev_base_lock, this
fix is correct.

Applied, thanks.
