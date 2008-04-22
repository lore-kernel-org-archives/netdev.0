From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [Bugme-new] [Bug 10473] New: Infinite loop "b44: eth0: powering down PHY"
Date: Tue, 22 Apr 2008 15:34:53 +0200
Message-ID: <200804221534.53825.mb@bu3sch.de>
References: <bug-10473-10286@http.bugzilla.kernel.org/> <200804212021.06367.mb@bu3sch.de> <9bfa9ae0804212001k5fd81642yba38386c92c8847e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	"Gary Zambrano" <zambrano@broadcom.com>
To: "Nelson A. de Oliveira" <naoliv@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs166246.vserver.de ([62.75.166.246]:35523 "EHLO
	vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752321AbYDVNf3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2008 09:35:29 -0400
In-Reply-To: <9bfa9ae0804212001k5fd81642yba38386c92c8847e@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 22 April 2008 05:01:54 Nelson A. de Oliveira wrote:
> Hi!
> 
> Maybe this can help:
> Using a new .config, I started to enable/disable options and test.
> What I found is that if I enable "3G/1G user/kernel split", the kernel
> works (it boots normally, the network interface works, etc). If I
> select "3G/1G user/kernel split (for full 1G low memory)" I get the
> infinite loop of "b44: eth0: powering down PHY".

Ah, so this bug isn't actually caused by a patch but rather by a
different config option.
I think we can't do much about it, currently. The device has strange
memory requirements and changing the split does actually break it.
This cannot be fixed until andi kleen's mask-allocator is merged.
This "bug" has always been there.

> Working config file (on 2.6.25) is attached.
> Diff to the non-working is below:
> 
> --- working_config	2008-04-21 23:42:40.000000000 -0300
> +++ not_working_config	2008-04-21 23:55:28.000000000 -0300
> @@ -1,7 +1,7 @@
>  #
>  # Automatically generated make config: don't edit
>  # Linux kernel version: 2.6.25
> -# Mon Apr 21 23:28:49 2008
> +# Mon Apr 21 23:43:04 2008
>  #
>  # CONFIG_64BIT is not set
>  CONFIG_X86_32=y
> @@ -228,12 +228,12 @@
>  # CONFIG_NOHIGHMEM is not set
>  CONFIG_HIGHMEM4G=y
>  # CONFIG_HIGHMEM64G is not set
> -CONFIG_VMSPLIT_3G=y
> -# CONFIG_VMSPLIT_3G_OPT is not set
> +# CONFIG_VMSPLIT_3G is not set
> +CONFIG_VMSPLIT_3G_OPT=y
>  # CONFIG_VMSPLIT_2G is not set
>  # CONFIG_VMSPLIT_2G_OPT is not set
>  # CONFIG_VMSPLIT_1G is not set
> -CONFIG_PAGE_OFFSET=0xC0000000
> +CONFIG_PAGE_OFFSET=0xB0000000
>  CONFIG_HIGHMEM=y
>  CONFIG_ARCH_FLATMEM_ENABLE=y
>  CONFIG_ARCH_SPARSEMEM_ENABLE=y
> 
> Can this be the cause?
> 
> Thank you!
> 
> Best regards,
> Nelson
> 



-- 
Greetings Michael.
