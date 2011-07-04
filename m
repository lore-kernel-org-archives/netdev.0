From: Martin Wilck <martin.wilck@ts.fujitsu.com>
Subject: [PATCH] fix WOL on 2nd port on i350
Date: Mon, 04 Jul 2011 16:17:43 +0200
Message-ID: <4E11CB87.5040806@ts.fujitsu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070904030301060002000805"
Cc: "Uhe, Rudolf" <rudolf.uhe@ts.fujitsu.com>
To: alexander.h.duyck@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070904030301060002000805
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

WOL fails on second port of a i350 network adapter with the latest
upstream kernel driver. It works with the sf.net driver 3.0.19. The
following patch seems to be missing upstream.

Regards,
Martin

-- 
Dr. Martin Wilck
PRIMERGY System Software Engineer
x86 Server Engineering

FUJITSU
Fujitsu Technology Solutions GmbH
Heinz-Nixdorf-Ring 1
33106 Paderborn, Germany
Phone:			++49 5251 525 2796
Fax:			++49 5251 525 2820
Email:			martin.wilck@ts.fujitsu.com
Internet:		http://ts.fujitsu.com
Company Details:	http://ts.fujitsu.com/imprint


--------------070904030301060002000805
Content-Type: text/plain;
 name="igb_i350_wol.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="igb_i350_wol.diff"

--- linus/drivers/net/igb/igb_main.c	2011-06-13 00:17:28.000000000 +0200
+++ linus/drivers/net/igb/igb_main.c.new	2011-07-04 14:24:00.000000000 +0200
@@ -1985,7 +1985,7 @@ static int __devinit igb_probe(struct pc
 
 	if (hw->bus.func == 0)
 		hw->nvm.ops.read(hw, NVM_INIT_CONTROL3_PORT_A, 1, &eeprom_data);
-	else if (hw->mac.type == e1000_82580)
+	else if (hw->mac.type >= e1000_82580)
 		hw->nvm.ops.read(hw, NVM_INIT_CONTROL3_PORT_A +
 		                 NVM_82580_LAN_FUNC_OFFSET(hw->bus.func), 1,
 		                 &eeprom_data);


--------------070904030301060002000805
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
All of the data generated in your IT infrastructure is seriously valuable.
Why? It contains a definitive record of application performance, security 
threats, fraudulent activity, and more. Splunk takes this data and makes 
sense of it. IT sense. And common sense.
http://p.sf.net/sfu/splunk-d2d-c2
--------------070904030301060002000805
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--------------070904030301060002000805--
