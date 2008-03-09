From: "Jon Schindler" <jkschind@gmail.com>
Subject: Re: [patch 16/17] drivers/net/8390.c: replace init_module&cleanup_module with module_init&module_exit
Date: Sun, 9 Mar 2008 00:56:25 -0600
Message-ID: <f68151390803082256i2bc7cd77x86d21aa915af8bfe@mail.gmail.com>
References: <200803042319.m24NJXjS002733@imap1.linux-foundation.org>
	 <47D1D70A.2070003@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, akpm@linux-foundation.org, netdev@vger.kernel.org,
	alan@lxorguk.ukuu.org.uk
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.189]:30041 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314AbYCIG40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2008 01:56:26 -0500
Received: by rv-out-0910.google.com with SMTP id k20so741243rvb.1
        for <netdev@vger.kernel.org>; Sat, 08 Mar 2008 22:56:26 -0800 (PST)
In-Reply-To: <47D1D70A.2070003@intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I actually ended up doing a resubmit, but forgot to send it to Jeff.
I'll send it in the next email.

Jon

On Fri, Mar 7, 2008 at 6:00 PM, Kok, Auke <auke-jan.h.kok@intel.com> wrote:
> akpm@linux-foundation.org wrote:
>  > From: Jon Schindler <jkschind@gmail.com>
>  >
>  > Replace init_module and cleanup_module with static functions and
>  > module_init/module_exit.
>  >
>  > Signed-off-by: Jon Schindler <jkschind@gmail.com>
>  > Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>
>  > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>
>  something went wrong here as this patch already appears to be in jeff's upstream
>  tree as commit 8724c2de65fe527f5b7aa662fcb8573fb8cd02f2, but breaks compile.
>
>  with CONFIG_NE2K_PCI=m:
>
>   CC [M]  drivers/net/8390.o
>  drivers/net/8390.c: In function '__inittest':
>  drivers/net/8390.c:60: error: 'ns8390_init_module' undeclared (first use in this
>  function)
>  drivers/net/8390.c:60: error: (Each undeclared identifier is reported only once
>  drivers/net/8390.c:60: error: for each function it appears in.)
>  make[2]: *** [drivers/net/8390.o] Error 1
>  make[1]: *** [drivers/net] Error 2
>  make: *** [drivers] Error 2
>
>
>  reverting the patch fixes the issue, but better would be to fix.
>
>  Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>  Cc: Jon Schindler <jkschind@gmail.com>
>
> Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>
>  Cc: Andrew Morton <akpm@linux-foundation.org>
>
>  ---
>  diff --git a/drivers/net/8390.c b/drivers/net/8390.c
>  index 0ed41a3..a499e86 100644
>
> --- a/drivers/net/8390.c
>  +++ b/drivers/net/8390.c
>  @@ -57,7 +57,7 @@ static void __exit ns8390_module_exit(void)
>   {
>   }
>
>  -module_init(ns8390_init_module);
>
>
> +module_init(ns8390_module_init);
>   module_exit(ns8390_module_exit);
>   #endif /* MODULE */
>   MODULE_LICENSE("GPL");
>
