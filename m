From: Ben Greear <greearb@candelatech.com>
Subject: Re: [Bugme-new] [Bug 10737] New: pktgen procfs problem
Date: Mon, 19 May 2008 17:26:42 -0700
Message-ID: <48321AC2.90500@candelatech.com>
References: <bug-10737-10286@http.bugzilla.kernel.org/>	 <20080517141036.d8f3c768.akpm@linux-foundation.org>	 <482F88DE.8090508@trash.net>	 <20080517215641.acb94677.akpm@linux-foundation.org>	 <48301BE0.9040907@trash.net> <48302E09.8080701@trash.net>	 <48304BB5.7090805@trash.net> <1211183642.9966.6.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	devzero@web.de, Robert Olsson <robert.olsson@its.uu.se>,
	Pavel Emelyanov <xemul@openvz.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([66.165.47.212]:60328 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755828AbYETA05 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 20:26:57 -0400
In-Reply-To: <1211183642.9966.6.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denis V. Lunev wrote:

> could you consider this preliminary patch? It fixes the problem for me
> and Pavel agrees with it.
> 
> The problem is that module_get is called for each file opening while
> module_put is called only when /proc inode is destroyed. So, lets put
> module counter if we are dealing with already initialised inode.
> 
> 
> ------------------------------------------------------------------------
> 
> diff --git a/fs/proc/inode.c b/fs/proc/inode.c
> index 6f4e8dc..b08d100 100644
> --- a/fs/proc/inode.c
> +++ b/fs/proc/inode.c
> @@ -425,7 +425,8 @@ struct inode *proc_get_inode(struct super_block *sb, unsigned int ino,
>  			}
>  		}
>  		unlock_new_inode(inode);
> -	}
> +	} else
> +	       module_put(de->owner);
>  	return inode;
>  
>  out_ino:

I just tested this and it seems to fix my problem (I applied this to 2.6.25 kernel).

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

