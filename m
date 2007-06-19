From: Keiichi KII <k-keiichi@bx.jp.nec.com>
Subject: Re: [RFC][PATCH -mm take5 6/7] add ioctls for adding/removing target
Date: Tue, 19 Jun 2007 19:04:45 +0900
Message-ID: <4677AA3D.7010604@bx.jp.nec.com>
References: <466FC455.5060001@bx.jp.nec.com> <466FC76A.6050006@bx.jp.nec.com> <a781481a0706131341k17170514q7a9d0ce052dbfe2a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matt Mackall <mpm@selenic.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Satyam Sharma <satyam.sharma@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758892AbXFSKFf@vger.kernel.org>
In-Reply-To: <a781481a0706131341k17170514q7a9d0ce052dbfe2a@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Satyam,

> *ugh*. I was wondering what a show-stopper this particular patch
> was -- introduces a couple of ioctl()'s, exports a new structure to
> userspace, adds a hitherto-unneeded header file, brings in
> tty_struct/tty_operations and ends up adding so much complexity/
> bloat to netconsole.c. Not only that, it must live together (and
> side-by-side) with the sysfs interface also, because the two of them
> do different things: sysfs to be able to modify target parameters at
> run-time and the ioctl()'s to dynamically add/remove targets. We
> can't really mkdir(2) or rmdir(2) in sysfs so the ioctl()'s are needed.
> 
> So may I suggest:
> 
> Just lose *both* the sysfs and ioctl() interfaces and use _configfs_.
> It is *precisely* the thing you need in your driver here -- the ability
> to create / destroy kernel objects (or config_items in configfs lingo)
> from _userspace_ via simple mkdir(2) and rmdir(2). And configfs
> makes changing multiple configurable parameters atomically trivial
> too, via rename(2) ... not to mention a sysfs+ioctls -> configfs
> conversion would help your patchset lose some weight too :-)

Stephen Hemminger previously advised me	about the user interface such as 
the following messages.

> Some other speculations:
> 1. Would it be possible to add ioctl's to /dev/console? This would be more in
>     keeping with older Unix style model.
> 
> 2. Using sysfs makes sense if there is a device object that exists to
>    add the sysfs attributes to.
> 
> 3. Procfs is handy for summary type tables.
> 
> 4. Netlink does feel like overkill for this. Although newer generic netlink
>    makes it easier.

So, I implemented ioctls to add/remove port like this patch on the tty driver.
But I'm going to search configfs. Thank you for you information.

Thanks
-- 
Keiichi KII
NEC Corporation OSS Platform Development Division
E-mail: k-keiichi@bx.jp.nec.com
