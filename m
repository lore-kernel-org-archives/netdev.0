From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/4] device_cgroup: prepare code for bpf-based
 device controller
Date: Thu, 02 Nov 2017 16:28:07 +0900 (KST)
Message-ID: <20171102.162807.1192486380016895082.davem@davemloft.net>
References: <20171101152037.3288-1-guro@fb.com>
        <20171101152037.3288-2-guro@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tj@kernel.org, ast@kernel.org,
        daniel@iogearbox.net, linux-kernel@vger.kernel.org
To: guro@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44498 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750907AbdKBH2L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 03:28:11 -0400
In-Reply-To: <20171101152037.3288-2-guro@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roman Gushchin <guro@fb.com>
Date: Wed, 1 Nov 2017 11:20:34 -0400

> diff --git a/include/linux/device_cgroup.h b/include/linux/device_cgroup.h
> index 8b64221b432b..25f1dc7673db 100644
> --- a/include/linux/device_cgroup.h
> +++ b/include/linux/device_cgroup.h
> @@ -1,16 +1,69 @@
>  #include <linux/fs.h>
>  
> +#define ACC_MKNOD 1
> +#define ACC_READ  2
> +#define ACC_WRITE 4
> +#define ACC_MASK (ACC_MKNOD | ACC_READ | ACC_WRITE)
> +
> +#define DEV_BLOCK 1
> +#define DEV_CHAR  2
> +#define DEV_ALL   4  /* this represents all devices */

When these macros existed solely inside of security/device_cgroup.c,
such naming was probably fine.

But once you move them into a global header file, we have to take
global namespace issues into consideration.

I would therefore like to ask that you give some kind of appropriate
prefix to the names of these macros, in order to make them more global
namespace friendly.

Thank you.
