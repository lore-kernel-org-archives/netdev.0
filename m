From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: Inconsistent use of size argument in kzalloc and memcpy in
 'drivers/net/ethernet/toshiba/ps3_gelic_wireless.c'
Date: Mon, 11 Apr 2016 12:00:04 +0200
Message-ID: <570B75A4.5070904@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: geoff@infradead.org, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, kernel-janitors@vger.kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

while looking at potential clean-up, I ended on the following code which 
looks spurious to me.

We allocate 'be16_to_cpu(scan_info->size)' bytes, but then copy 
'scan_info->size'.
This is not consistent.


I don't know which one is the correct one.


CJ

--- drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
+++ /tmp/cocci-output-24201-0dddbd-ps3_gelic_wireless.c
@@ -1616,13 +1616,10 @@ static void gelic_wl_scan_complete_event
          target->valid = 1;
          target->eurus_index = i;
          kfree(target->hwinfo);
-        target->hwinfo = kzalloc(be16_to_cpu(scan_info->size),
-                     GFP_KERNEL);
          if (!target->hwinfo)
              continue;

          /* copy hw scan info */
-        memcpy(target->hwinfo, scan_info, scan_info->size);
          target->essid_len = strnlen(scan_info->essid,
                          sizeof(scan_info->essid));
          target->rate_len = 0;

