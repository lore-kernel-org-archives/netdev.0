From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next] Documentation: remove obsolete networking/multicast.txt file
Date: Mon, 21 Jan 2013 11:17:41 -0500
Message-ID: <1358785061-17985-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:54776 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753763Ab3AUQRw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 11:17:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original intent of this file was to list limitations in
drivers/hardware relating to multicast use, back when some
modest hardware from the early 1990s did not support things
we might take for granted today.

I was intending to delete some now-gone MCA/token ring entries
in this file, but once I opened it, I found it only contained
information on the earliest (pre-2000) linux networking drivers.

Checking the git history shows that the file hasn't been touched
since 2005.  Clearly nobody is actively consulting this file
as a meaningful reference.

Rather than add a "YES YES YES" line for all of the drivers we
currently have, lets just take advantage of the fact that nobody
is using the file to delete it.

This has the side benefit of not having to do a line-by-line
deletion of the file content as each older driver is expired.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 Documentation/networking/00-INDEX      |  2 --
 Documentation/networking/multicast.txt | 63 ----------------------------------
 2 files changed, 65 deletions(-)
 delete mode 100644 Documentation/networking/multicast.txt

diff --git a/Documentation/networking/00-INDEX b/Documentation/networking/00-INDEX
index 2cc3c77..1abfff2 100644
--- a/Documentation/networking/00-INDEX
+++ b/Documentation/networking/00-INDEX
@@ -126,8 +126,6 @@ ltpc.txt
 	- the Apple or Farallon LocalTalk PC card driver
 mac80211-injection.txt
 	- HOWTO use packet injection with mac80211
-multicast.txt
-	- Behaviour of cards under Multicast
 multiqueue.txt
 	- HOWTO for multiqueue network device support.
 netconsole.txt
diff --git a/Documentation/networking/multicast.txt b/Documentation/networking/multicast.txt
deleted file mode 100644
index b06c8c6..0000000
--- a/Documentation/networking/multicast.txt
+++ /dev/null
@@ -1,63 +0,0 @@
-Behaviour of Cards Under Multicast
-==================================
-
-This is how they currently behave, not what the hardware can do--for example,
-the Lance driver doesn't use its filter, even though the code for loading
-it is in the DEC Lance-based driver.
-
-The following are requirements for multicasting 
------------------------------------------------
-AppleTalk	Multicast	hardware filtering not important but
-				 avoid cards only doing promisc
-IP-Multicast	Multicast	hardware filters really help
-IP-MRoute	AllMulti	hardware filters are of no help
-
-
-Board		Multicast	AllMulti	Promisc		Filter
-------------------------------------------------------------------------
-3c501		YES		YES		YES		Software
-3c503		YES		YES		YES		Hardware
-3c505		YES		NO		YES		Hardware
-3c507		NO		NO		NO		N/A
-3c509		YES		YES		YES		Software
-3c59x		YES		YES		YES		Software
-ac3200		YES		YES		YES		Hardware
-apricot		YES		PROMISC		YES		Hardware
-arcnet		NO		NO		NO		N/A
-at1700		PROMISC		PROMISC		YES		Software
-atp		PROMISC		PROMISC		YES		Software
-cs89x0		YES		YES		YES		Software
-de4x5		YES		YES		YES		Hardware
-de600		NO		NO		NO		N/A
-de620		PROMISC		PROMISC		YES		Software
-depca		YES		PROMISC		YES		Hardware
-dmfe		YES		YES		YES		Software(*)
-e2100		YES		YES		YES		Hardware
-eepro		YES		PROMISC		YES		Hardware
-eexpress	NO		NO		NO		N/A
-ewrk3		YES		PROMISC		YES		Hardware
-hp-plus		YES		YES		YES		Hardware
-hp		YES		YES		YES		Hardware
-hp100		YES		YES		YES		Hardware
-ibmtr		NO		NO		NO		N/A
-ioc3-eth	YES		YES		YES		Hardware
-lance		YES		YES		YES		Software(#)
-ne		YES		YES		YES		Hardware
-ni52		<------------------ Buggy ------------------>
-ni65		YES		YES		YES		Software(#)
-seeq		NO		NO		NO		N/A
-sgiseek		<------------------ Buggy ------------------>
-smc-ultra	YES		YES		YES		Hardware
-sunlance	YES		YES		YES		Hardware
-tulip		YES		YES		YES		Hardware
-wavelan		YES		PROMISC		YES		Hardware
-wd		YES		YES		YES		Hardware
-xirc2ps_cs	YES		YES		YES		Hardware
-znet		YES		YES		YES		Software
-
-
-PROMISC = This multicast mode is in fact promiscuous mode. Avoid using
-cards who go PROMISC on any multicast in a multicast kernel.
-
-(#) = Hardware multicast support is not used yet.
-(*) = Hardware support for Davicom 9132 chipset only.
-- 
1.8.1
