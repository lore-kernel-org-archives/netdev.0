From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH net-next 1/4] soreuseport: define reuseport groups
Date: Tue, 22 Dec 2015 17:39:51 -0500
Message-ID: <CAEfhGiwFxK8KhzpD=v96F-78vmtnyy-NTdh96CtDDm9PPkSG1A@mail.gmail.com>
References: <1450814710-17850-2-git-send-email-kraigatgoog@gmail.com>
	<201512230632.1e6h4wUg%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kbuild-all@01.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f196.google.com ([209.85.217.196]:36237 "EHLO
	mail-lb0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751765AbbLVWjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 17:39:54 -0500
Received: by mail-lb0-f196.google.com with SMTP id ti8so4508921lbb.3
        for <netdev@vger.kernel.org>; Tue, 22 Dec 2015 14:39:53 -0800 (PST)
Received: from mail-lf0-f52.google.com (mail-lf0-f52.google.com. [209.85.215.52])
        by smtp.gmail.com with ESMTPSA id pd9sm6014345lbc.48.2015.12.22.14.39.52
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Dec 2015 14:39:52 -0800 (PST)
Received: by mail-lf0-f52.google.com with SMTP id p203so139039662lfa.0
        for <netdev@vger.kernel.org>; Tue, 22 Dec 2015 14:39:52 -0800 (PST)
In-Reply-To: <201512230632.1e6h4wUg%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 22, 2015 at 5:11 PM, kbuild test robot <lkp@intel.com> wrote:
> Hi Craig,
>
> [auto build test ERROR on net-next/master]
>
> url:    https://github.com/0day-ci/linux/commits/Craig-Gallek/Faster-SO_REUSEPORT/20151223-040911
> config: arm-mvebu_v7_defconfig (attached as .config)
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=arm
>
> Note: the linux-review/Craig-Gallek/Faster-SO_REUSEPORT/20151223-040911 HEAD 660edb1fa7e1a2bf71ef9cbf4555cda4af95ea58 builds fine.
>       It only hurts bisectibility.
>
> All errors (new ones prefixed by >>):
>
>    In file included from include/linux/spinlock_types.h:13:0,
>                     from include/net/sock_reuseport.h:4,
>                     from net/core/sock_reuseport.c:7:
>>> arch/arm/include/asm/spinlock_types.h:12:3: error: unknown type name 'u32'
>       u32 slock;
>       ^
>>> arch/arm/include/asm/spinlock_types.h:18:4: error: unknown type name 'u16'
>        u16 owner;
>        ^
>    arch/arm/include/asm/spinlock_types.h:19:4: error: unknown type name 'u16'
>        u16 next;
>        ^
>    arch/arm/include/asm/spinlock_types.h:28:2: error: unknown type name 'u32'
>      u32 lock;
>      ^
>
> vim +/u32 +12 arch/arm/include/asm/spinlock_types.h
>
> fb1c8f93 include/asm-arm/spinlock_types.h      Ingo Molnar 2005-09-10   6  #endif
> fb1c8f93 include/asm-arm/spinlock_types.h      Ingo Molnar 2005-09-10   7
> 546c2896 arch/arm/include/asm/spinlock_types.h Will Deacon 2012-07-06   8  #define TICKET_SHIFT 16
> 546c2896 arch/arm/include/asm/spinlock_types.h Will Deacon 2012-07-06   9
> fb1c8f93 include/asm-arm/spinlock_types.h      Ingo Molnar 2005-09-10  10  typedef struct {
> 546c2896 arch/arm/include/asm/spinlock_types.h Will Deacon 2012-07-06  11       union {
> 546c2896 arch/arm/include/asm/spinlock_types.h Will Deacon 2012-07-06 @12               u32 slock;
> 546c2896 arch/arm/include/asm/spinlock_types.h Will Deacon 2012-07-06  13               struct __raw_tickets {
> 546c2896 arch/arm/include/asm/spinlock_types.h Will Deacon 2012-07-06  14  #ifdef __ARMEB__
> 546c2896 arch/arm/include/asm/spinlock_types.h Will Deacon 2012-07-06  15                       u16 next;
> 546c2896 arch/arm/include/asm/spinlock_types.h Will Deacon 2012-07-06  16                       u16 owner;
> 546c2896 arch/arm/include/asm/spinlock_types.h Will Deacon 2012-07-06  17  #else
> 546c2896 arch/arm/include/asm/spinlock_types.h Will Deacon 2012-07-06 @18                       u16 owner;
> 546c2896 arch/arm/include/asm/spinlock_types.h Will Deacon 2012-07-06  19                       u16 next;
> 546c2896 arch/arm/include/asm/spinlock_types.h Will Deacon 2012-07-06  20  #endif
> 546c2896 arch/arm/include/asm/spinlock_types.h Will Deacon 2012-07-06  21               } tickets;
>
> :::::: The code at line 12 was first introduced by commit
> :::::: 546c2896a42202dbc7d02f7c6ec9948ac1bf511b ARM: 7446/1: spinlock: use ticket algorithm for ARMv6+ locking implementation
>
> :::::: TO: Will Deacon <will.deacon@arm.com>
> :::::: CC: Russell King <rmk+kernel@arm.linux.org.uk>
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

ACK, I don't even need spinlock_types for this file anymore (though it
may be worth fixing the arm version to include linux/types.h).  Will
remove for v2
