From: Marc Zyngier <mzyngier@freesurf.fr>
Subject: Re: 2.6.4-rc1 + hp100 EISA, not working
Date: Mon, 01 Mar 2004 11:25:25 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <wrpk724yicq.fsf@hina.wild-wind.fr.eu.org>
References: <Pine.LNX.4.58.0402292149230.25624@don.falconne.eu.org>
Reply-To: mzyngier@freesurf.fr
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: pawel.sokolowski@muflon.linux.pl
In-Reply-To: <Pine.LNX.4.58.0402292149230.25624@don.falconne.eu.org> (Pawe's
 message of "Sun, 29 Feb 2004 22:06:16 +0100 (CET)")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>>>> "Pawel" == Pawe  <Pawe> writes:

Pawel> On 2.6.3 it just Oopsed and didn't work. On 2.6.4-rc1 it does
Pawel> not oops but it doesn't work (neither as module nor as build in kernel).

Note that hp100 in 2.6.4-rc1 is still broken wrt EISA probing, since
it lacks the terminating entry in the EISA ID list. This one-liner
should take care of random crashes that are often reported to LKML :

===== drivers/net/hp100.c 1.24 vs edited =====
--- 1.24/drivers/net/hp100.c	Wed Feb 18 13:39:41 2004
+++ edited/drivers/net/hp100.c	Mon Mar  1 11:18:00 2004
@@ -201,6 +201,7 @@
 	{ "HWP1990" }, /* HP J2577 */
 	{ "CPX0301" }, /* ReadyLink ENET100-VG4 */
 	{ "CPX0401" }, /* FreedomLine 100/VG */
+	{ "" }	       /* Mandatory final entry ! */
 };
 MODULE_DEVICE_TABLE(eisa, hp100_eisa_tbl);
 #endif

Jeff, would you please push this to Linus ?

      M.
-- 
Places change, faces change. Life is so very strange.
