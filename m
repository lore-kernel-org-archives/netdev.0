From: "Satyam Sharma" <satyam.sharma@gmail.com>
Subject: Re: [RFC][PATCH -mm take5 5/7] switch function of netpoll
Date: Wed, 13 Jun 2007 22:34:07 +0530
Message-ID: <a781481a0706131004q722bb409tcd4e1d13102bfb8c@mail.gmail.com>
References: <466FC455.5060001@bx.jp.nec.com> <466FC72A.3090508@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Matt Mackall" <mpm@selenic.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"David Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "Keiichi KII" <k-keiichi@bx.jp.nec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.230]:61293 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758457AbXFMREI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 13:04:08 -0400
Received: by nz-out-0506.google.com with SMTP id n1so287614nzf
        for <netdev@vger.kernel.org>; Wed, 13 Jun 2007 10:04:08 -0700 (PDT)
In-Reply-To: <466FC72A.3090508@bx.jp.nec.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Keiichi,

On 6/13/07, Keiichi KII <k-keiichi@bx.jp.nec.com> wrote:
> From: Keiichi KII <k-keiichi@bx.jp.nec.com>
>
> This patch contains switch function of netpoll.
>
> If "enabled" attribute of certain port is '1', this port is used
> and the configurations of this port are unable to change.
>
> If "enabled" attribute of certain port is '0', this port isn't used
> and the configurations of this port are able to change.
>
> -+- /sys/class/misc/
> |-+- netconsole/
>   |-+- port1/
>   | |--- id          [r--r--r--]  id
>   | |--- enabled     [rw-r--r--]  0: disable 1: enable, writable
>   | ...
>   |--- port2/
>   ...
>
> Signed-off-by: Keiichi KII <k-keiichi@bx.jp.nec.com>
> Signed-off-by: Takayoshi Kochi <t-kochi@bq.jp.nec.com>
> ---
> Index: mm/drivers/net/netconsole.c
> ===================================================================
> --- mm.orig/drivers/net/netconsole.c
> +++ mm/drivers/net/netconsole.c
> @@ -71,6 +71,7 @@ struct netconsole_target {
>         struct list_head list;
>         struct kobject obj;
>         int id;
> +       int enabled;
>         struct netpoll np;
>  };

I really think you need to document/comment the struct members.
The newly introduced "enabled" for example, is serving a dual-purpose
in your code here (like you mention in the Changelog). It's used not
only to enable/disable a target, but also to ensure atomicity when
changing the (multiple) configurable parameters of a given target ...
the first purpose is self-evident from the name, but the second is
non-obvious. A sysfs node is also a userspace interface, so some
explicit mention of this is required.

Satyam
