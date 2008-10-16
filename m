From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/7] netns ebtables: part 1
Date: Thu, 16 Oct 2008 15:12:03 +0200
Message-ID: <48F73DA3.1030401@trash.net>
References: <20081015042014.GE24058@x200.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070108090603000508080903"
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	containers@osdl.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081015042014.GE24058@x200.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070108090603000508080903
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Alexey Dobriyan wrote:
> One needs to add ".netns_ok = 1" to igmp_protocol to test all of this
> with ebtables() in netns.
> -------------------------------------------------
> [PATCH 1/7] netns ebtables: part 1
> 
> * make list of ebt_tables per-netns
> * propagate netns from userspace, register table in passed netns
> * temporarily register every ebt_table in init_net

I'm not queuing patches for 2.6.29 yet, please resend the entire
batch once Dave opens his net-next tree again.

> --- a/include/net/netns/x_tables.h
> +++ b/include/net/netns/x_tables.h
> @@ -6,5 +6,6 @@
>  
>  struct netns_xt {
>  	struct list_head tables[NPROTO];
> +	struct list_head ebt_tables;

This could just use tables[NFPROTO_BRIDGE].

BTW, I have a patch queued to change NPROTO to NFPROTO_NUMPROTO in
struct netns_xt since we've decoupled the netfilter values from
generic procotol values (attached in case you would like to add
an ACK).



--------------070108090603000508080903
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit c985d88e7ae4f45d50cca80033429c7270a8c185
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu Oct 16 13:14:26 2008 +0200

    netfilter: netns: use NFPROTO_NUMPROTO instead of NUMPROTO for tables array
    
    The netfilter families have been decoupled from regular protocol families.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/netns/x_tables.h b/include/net/netns/x_tables.h
index 0cb63ed..b809397 100644
--- a/include/net/netns/x_tables.h
+++ b/include/net/netns/x_tables.h
@@ -2,9 +2,9 @@
 #define __NETNS_X_TABLES_H
 
 #include <linux/list.h>
-#include <linux/net.h>
+#include <linux/netfilter.h>
 
 struct netns_xt {
-	struct list_head tables[NPROTO];
+	struct list_head tables[NFPROTO_NUMPROTO];
 };
 #endif

--------------070108090603000508080903--
