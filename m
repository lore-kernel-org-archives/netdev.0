From: Thomas Backlund <tmb@mageia.org>
Subject: Re: if_bridge.h: include in6.h for struct in6_addr use
Date: Sun, 13 Jan 2013 22:05:57 +0200
Message-ID: <50F313A5.3020707@mageia.org>
References: <50F2FF1B.3020708@mageia.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, libvirt-list@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.multi.fi ([85.134.37.151]:44082 "EHLO smtp.multi.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756029Ab3AMUGI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Jan 2013 15:06:08 -0500
In-Reply-To: <50F2FF1B.3020708@mageia.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Backlund skrev 13.1.2013 20:38:
> patch both inline and attached as thunderbird tends to mess up ...

> -----
>
> if_bridge.h uses struct in6_addr ip6; but does not include the in6.h
> header.
>
> Found by trying to build libvirt and connman against 3.8-rc3 headers.
>

Ok,
ignore this patch, it's not the correct fix as it introduces
redefinitions...

Btw, the error that I hit that made me suggest this fix was libvirt
config check bailing out:

config.log:/usr/include/linux/if_bridge.h:173:20: error: field 'ip6' has 
incomplete type

> Reported-by: Colin Guthrie <colin@mageia.org>
> Reported-by: Christiaan Welvaart <cjw@daneel.dyndns.org>
> Signed-off-by: Thomas Backlund <tmb@mageia.org>
>
> --
>
> diff -Nurp linux-3.8-rc3/include/uapi/linux/if_bridge.h
> linux-3.8-rc3.fix/include/uapi/linux/if_bridge.h
> --- linux-3.8-rc3/include/uapi/linux/if_bridge.h        2013-01-13
> 20:09:54.257271755 +0200
> +++ linux-3.8-rc3.fix/include/uapi/linux/if_bridge.h    2013-01-13
> 20:15:04.153676151 +0200
> @@ -14,6 +14,7 @@
>   #define _UAPI_LINUX_IF_BRIDGE_H
>
>   #include <linux/types.h>
> +#include <linux/in6.h>
>
>   #define SYSFS_BRIDGE_ATTR      "bridge"
>   #define SYSFS_BRIDGE_FDB       "brforward"
>
>
> -----
> Thomas
>
--
Thomas
