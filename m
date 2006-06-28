From: James Morris <jmorris@namei.org>
Subject: Re: [Patch 1/1] AF_UNIX Datagram getpeersec (with latest updates)
Date: Tue, 27 Jun 2006 21:33:17 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0606272130080.6477@d.namei>
References: <20060628013428.GA31240@jiayuguan.watson.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	chrisw@osdl.org, Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Smalley <sds@tycho.nsa.gov>, tjaeger@cse.psu.edu,
	Andrew Morton <akpm@osdl.org>, latten@austin.ibm.com,
	sergeh@us.ibm.com, gcwilson@us.ibm.com, czhang.us@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.sea5.speakeasy.net ([69.17.117.8]:55727 "EHLO
	mail6.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932675AbWF1BdU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 21:33:20 -0400
To: Catherine Zhang <cxzhang@watson.ibm.com>
In-Reply-To: <20060628013428.GA31240@jiayuguan.watson.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 27 Jun 2006, Catherine Zhang wrote:

> diff -puN security/selinux/exports.c~lsm-secpeer-unix security/selinux/exports.c
> --- linux-2.6.17-rc6-mm2-JM/security/selinux/exports.c~lsm-secpeer-unix	2006-06-27 18:15:10.914669944 -0400
> +++ linux-2.6.17-rc6-mm2-JM-cxzhang/security/selinux/exports.c	2006-06-27 18:16:31.502418744 -0400
> @@ -17,6 +17,7 @@
>  #include <linux/selinux.h>
>  #include <linux/fs.h>
>  #include <linux/ipc.h>
> +#include <net/sock.h>
>  
>  #include "security.h"
>  #include "objsec.h"
> @@ -72,6 +73,16 @@ void selinux_get_task_sid(struct task_st
>  	*sid = 0;
>  }
>  
> +void selinux_get_sock_sid(struct socket *sock, u32 *sid)
> +{
> +	if (selinux_enabled) {
> +		const struct inode *inode = SOCK_INODE(sock);
> +		selinux_get_inode_sid(inode, sid);
> +		return;
> +	}
> +	*sid = 0;
> +}
> +


Just one more thing, we don't need to export this function now.



- James
-- 
James Morris
<jmorris@namei.org>
