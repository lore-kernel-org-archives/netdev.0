From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] VSOCK: Fix misc device registration
Date: Thu, 25 Apr 2013 04:22:28 -0400 (EDT)
Message-ID: <20130425.042228.2204533400325888779.davem@davemloft.net>
References: <1366785232-15653-1-git-send-email-asias@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acking@vmware.com, dtor@vmware.com,
	grantr@vmware.com, linux-kernel@vger.kernel.org
To: asias@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1366785232-15653-1-git-send-email-asias@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Asias He <asias@redhat.com>
Date: Wed, 24 Apr 2013 14:33:52 +0800

> When we call vsock_core_init to init VSOCK the second time,
> vsock_device.minor still points to the old dynamically allocated minor
> number. misc_register will allocate it for us successfully as if we were
> asking for a static one. However, when other user call misc_register to
> allocate a dynamic minor number, it will give the one used by
> vsock_core_init(), causing this:
> 
>   [  405.470687] WARNING: at fs/sysfs/dir.c:536 sysfs_add_one+0xcc/0xf0()
>   [  405.470689] Hardware name: OptiPlex 790
>   [  405.470690] sysfs: cannot create duplicate filename '/dev/char/10:54'
> 
> Always set vsock_device.minor to MISC_DYNAMIC_MINOR before we
> register.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Andy King <acking@vmware.com>
> Cc: Dmitry Torokhov <dtor@vmware.com>
> Cc: Reilly Grant <grantr@vmware.com>
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Signed-off-by: Asias He <asias@redhat.com>

Applied.
