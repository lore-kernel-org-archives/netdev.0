From: Michal Schmidt <xschmi00@stud.feec.vutbr.cz>
Subject: [PATCH] airo.c - don't clear FLAG_RADIO_DOWN on resume
Date: Fri, 13 Aug 2004 00:25:06 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <411BEE42.4050806@stud.feec.vutbr.cz>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040306020700070807040203"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: achirica@ttd.net
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040306020700070807040203
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hello,

According to comments in airo.c the flag FLAG_RADIO_DOWN means:
   Radio disabled via "ifconfig ethX down".
airo_pci_resume clears this flag.
This causes a little problem I can reproduce on my IBM ThinkPad R40 with 
Cisco Aironet mini-PCI card (MPI350) with these steps:
1) ifup eth0 => card works OK, radio status LED indicator is on
2) ifdown eth0 => LED turns off
3) hibernate using swsuspend
4) resume from swsuspend
Result: interface eth0 is down, but the LED indicates that radio is on.
Expected result: interface eth0 is down, so the radio should be off.

I think that airo_pci_resume shouldn't mess with FLAG_RADIO_DOWN. I have 
removed the line and now everything works as expected. One-line patch 
attached.


Michal Schmidt

--------------040306020700070807040203
Content-Type: text/x-patch;
 name="airo-resume-radio.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="airo-resume-radio.patch"

--- linux-2.6.8-rc4-bk2/drivers/net/wireless/airo.c	2004-08-12 22:00:42.000000000 +0200
+++ linux-2.6.8-rc4-bk2-mich/drivers/net/wireless/airo.c	2004-08-12 22:09:15.000000000 +0200
@@ -5520,7 +5520,6 @@ static int airo_pci_resume(struct pci_de
 		mpi_init_descriptors(ai);
 		setup_card(ai, dev->dev_addr, 0);
 		clear_bit(FLAG_RADIO_OFF, &ai->flags);
-		clear_bit(FLAG_RADIO_DOWN, &ai->flags);
 		clear_bit(FLAG_PENDING_XMIT, &ai->flags);
 	} else {
 		OUT4500(ai, EVACK, EV_AWAKEN);

--------------040306020700070807040203--
