From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH] ehea: Fix: Remove adapter from adapter list in error
 path
Date: Wed, 11 Feb 2009 15:15:34 +0100
Message-ID: <4992DD86.1030607@s5r6.in-berlin.de>
References: <200902111329.02954.hannes.hering@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	ossrosch@linux.vnet.ibm.com, ossthema@de.ibm.com,
	raisch@de.ibm.com, themann@de.ibm.com, osstklei@de.ibm.com
To: Hannes Hering <hannes.hering@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756452AbZBKOP7@vger.kernel.org>
In-Reply-To: <200902111329.02954.hannes.hering@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hannes Hering wrote:
> Remove adapter from adapter list before freeing data structure in error path.
...
> --- linux-2.6.29-rc4/drivers/net/ehea/ehea_main.c	2009-02-11 13:13:47.812542928 +0100
> +++ patched_kernel/drivers/net/ehea/ehea_main.c	2009-02-11 13:14:04.197540184 +0100
> @@ -3448,6 +3448,7 @@ out_kill_eq:
>  	ehea_destroy_eq(adapter->neq);
>  
>  out_free_ad:
> +	list_del(&adapter->list);
>  	kfree(adapter);
>  
>  out:

On a related note, ehea_set_mac_addr()/ehea_update_bcmc_registrations()
accesses adapter_list without serialization by ehea_fw_handles.lock and
thus apparently unsafely.

There may be other unsafe accesses of adapter_list; that's just the
first one which I spotted.
-- 
Stefan Richter
-=====-==--= --=- -=-==
http://arcgraph.de/sr/
