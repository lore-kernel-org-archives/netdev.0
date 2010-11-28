From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 4/4] zd1211rw: remove unnecessary [kv][mcz]alloc casts
Date: Sun, 28 Nov 2010 02:13:52 -0800
Message-ID: <1290939232.16349.32.camel@Joe-Laptop>
References: <cover.1290934782.git.joe@perches.com>
	 <704bdd89d630b364043ac7a9ec0a110d311a17a2.1290934782.git.joe@perches.com>
	 <1290935566.3467.0.camel@jlt3.sipsolutions.net>
	 <1290936047.16349.13.camel@Joe-Laptop>
	 <1290936606.3467.2.camel@jlt3.sipsolutions.net>
	 <1290937845.16349.16.camel@Joe-Laptop>
	 <1290938527.3467.5.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>, Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1290938527.3467.5.camel-8upI4CBIZJIJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 2010-11-28 at 11:02 +0100, Johannes Berg wrote:
> On Sun, 2010-11-28 at 01:50 -0800, Joe Perches wrote:
> > Good memory you have Johannes...
> > http://marc.info/?l=linux-netdev&m=117113743902549&w=3
> I, err, not really, all this isn't making a whole lot of sense to me
> right now :-)
> The only thing I remembered was that there was something weird with
> zd_addr_t ...

Yes.  It's marked __nocast.

> Did sparse become more reliable in face of errors?

Apparently not.

If the kmalloc cast in zd_chip is removed:

$ make C=1 drivers/net/wireless/zd1211rw/zd_chip.o
  CHK     include/linux/version.h
  CHK     include/generated/utsrelease.h
  CALL    scripts/checksyscalls.sh
  CHECK   drivers/net/wireless/zd1211rw/zd_chip.c
arch/x86/include/asm/uaccess_32.h:197:9: error: attribute 'error': unknown attribute
  CC      drivers/net/wireless/zd1211rw/zd_chip.o
$

If the __compiletime_<foo> uses in uaccess_32.h are removed,
and the kmalloc cast in zd_chip is also removed:

$ make C=1 drivers/net/wireless/zd1211rw/zd_chip.o
  CHK     include/linux/version.h
  CHK     include/generated/utsrelease.h
  CC      arch/x86/kernel/asm-offsets.s
  GEN     include/generated/asm-offsets.h
  CALL    scripts/checksyscalls.sh
  CHECK   drivers/net/wireless/zd1211rw/zd_chip.c
drivers/net/wireless/zd1211rw/zd_chip.c:121:22: warning: implicit cast to nocast type
  CC      drivers/net/wireless/zd1211rw/zd_chip.o
$

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
