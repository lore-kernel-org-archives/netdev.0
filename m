From: Adrian Bunk <bunk@stusta.de>
Subject: net/tipc/bcast.c:tipc_bcbearer_send() stack usage
Date: Mon, 30 Jan 2006 03:47:48 +0100
Message-ID: <20060130024748.GI3777@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751222AbWA3Cru@vger.kernel.org>
To: per.liden@ericsson.com, jon.maloy@ericsson.com,
	allan.stephens@windriver.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From net/tipc/bcast.c:

<--  snip  -->

...
int tipc_bcbearer_send(struct sk_buff *buf,
                       struct tipc_bearer *unused1,
                       struct tipc_media_addr *unused2)
{
        static int send_count = 0;

        struct node_map remains;
        struct node_map remains_new;
...

<--  snip  -->


You've just allocated 2*516 Bytes for the two structs from a stack that 
might only be 4 kB altogether.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
