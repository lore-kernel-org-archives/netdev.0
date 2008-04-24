From: "Gordon Farquharson" <gordonfarquharson@gmail.com>
Subject: Re: physmap and "request_module: runaway loop modprobe net-pf-1"
Date: Wed, 23 Apr 2008 22:01:07 -0600
Message-ID: <97a0a9ac0804232101i71bfff22o723e2aaa80b09c2f@mail.gmail.com>
References: <97a0a9ac0803112235l157706adoa84b131549a46049@mail.gmail.com>
	 <20080311225926.6515e18c.akpm@linux-foundation.org>
	 <1208867831.9212.582.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mtd@lists.infradead.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: "David Woodhouse" <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.183]:11667 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720AbYDXEBI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 00:01:08 -0400
Received: by el-out-1112.google.com with SMTP id n30so1118233elf.21
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2008 21:01:07 -0700 (PDT)
In-Reply-To: <1208867831.9212.582.camel@pmac.infradead.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

On Tue, Apr 22, 2008 at 6:37 AM, David Woodhouse <dwmw2@infradead.org> wrote:
> On Tue, 2008-03-11 at 22:59 -0700, Andrew Morton wrote:
>
> > Now, af_unix_init() uses module_init(), which is really __initcall(), which
>  > is really device_initcall() (ug, don't ask).
>
>  ... which is really __define_initcall("6", ...);.
>
>
>  > So you can do what you're sugesting here by locating the caller/callers of
>  > parse_mtd_partitions() and marking them late_initcall().
>
>  Better still, just initialise af_unix earlier so that it's there before
>  any normal drivers which happen to call request_module(). Since core
>  network stuff is initialised with subsys_initcall() which is really
>  __define_initcall("4", ...), we can initialise af_unix with
>  fs_initcall() which is really __define_initcall("5", ...).

I tested the patch you sent. It fixes the runaway modprobe messages,
but I get a modprobe error (see below) with the Debian kernel I used
to test the patch because modules.dep does not exist in the initramfs
(should it?). In my kernel config, I did not enable
CONFIG_MTD_CMDLINE_PARTS and I set CONFIG_MTD_REDBOOT_PARTS=m but the
redboot module was not included in the initramfs so it could not be
loaded, hence the messages saying that the parsing schemes are not
available.

[    4.790000] physmap platform flash device: 00080000 at f0000000
[    4.800000] Found: ST M29W400DB
[    4.800000] physmap-flash.0: Found 1 x16 devices at 0x0 in 16-bit bank
[    4.810000] number of JEDEC chips: 1
[    4.810000] cfi_cmdset_0002: Disabling erase-suspend-program due to
code brokenness.
modprobe: FATAL: Could not load
/lib/modules/2.6.25-trunk-iop32x/modules.dep: No such file or
directory

[    4.900000] cmdlinepart partition parsing not available
modprobe: FATAL: Could not load
/lib/modules/2.6.25-trunk-iop32x/modules.dep: No such file or
directory

[    4.970000] RedBoot partition parsing not available

I guess the question is which patch (if either) is more appealing.

Gordon

-- 
Gordon Farquharson
GnuPG Key ID: 32D6D676
