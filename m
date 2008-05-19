From: Alexey Dobriyan <adobriyan@parallels.com>
Subject: Re: [Bugme-new] [Bug 10737] New: pktgen procfs problem
Date: Mon, 19 May 2008 19:19:35 +0400
Message-ID: <200805191919.35988.adobriyan@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, kaber@trash.net, den@openvz.org,
	netdev@vger.kernel.org, devzero@web.de
To: bugme-daemon@bugzilla.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:3213 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759933AbYESPTu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2008 11:19:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> remove_proc_entry: removing non-empty directory 'net/pktgen', leaking at least 'kpktgend_1'

> --- a/fs/proc/inode.c
> +++ b/fs/proc/inode.c
> @@ -425,7 +425,8 @@ struct inode *proc_get_inode(struct super_block *sb, unsigned int ino,
>                         }
>                 }
>                 unlock_new_inode(inode);
> -       }
> +       } else
> +              module_put(de->owner);
>         return inode;
>  
>  out_ino:

For the record, I fail to see how this can fix original bugreport:
If rmmod started and proc warnings were spewed, module's refcount was 0,
so positive refcount leak can't do that.

Roland, was it just modprobe/rmmod or something else?
