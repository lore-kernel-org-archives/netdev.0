From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e1000 driver problems
Date: Tue, 27 Nov 2007 10:23:00 -0800
Message-ID: <474C6084.9000301@intel.com>
References: <20061017205316.25914.qmail@web83109.mail.mud.yahoo.com> <45354850.6050900@intel.com> <20071120143803.GA5638@ics.muni.cz> <474B5610.4030800@intel.com> <20071127150700.GB4365@ics.muni.cz> <474C4A74.90705@intel.com> <20071127173146.GG4365@ics.muni.cz> <474C5678.3060609@intel.com> <20071127174456.GH4365@ics.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58655 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754723AbXK0SXc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2007 13:23:32 -0500
In-Reply-To: <20071127174456.GH4365@ics.muni.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lukas Hejtmanek wrote:
> On Tue, Nov 27, 2007 at 09:40:08AM -0800, Kok, Auke wrote:
>>> I'm afraid, I'm missing the point as you have stated that in-kernel drivers
>>> have problem with suspicious board hang...
>> my mistake, sorry for that confusion.
>>
>> the fake hangs on 82562/6 devices occur on 10mbit link only. You can check in the
>> code for a line that says:
>>
>> 	adapter->tx_timeout_factor = 8;
>>
>> change that number to 16 to cope with the problem on 10mbit link partners.
>> However this won't fix the issue on 100mbit partners and we need to
>> investigate that if that is the case.
> 
> 100mbit is the issue in my case.
> 

can you see if your problem goes away with this patch?

---
e1000: increase tx timeout factor for 100mbit speeds

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index b7c3070..2e46a15 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2601,7 +2601,7 @@ e1000_watchdog(unsigned long data)
                        case SPEED_100:
                                txb2b = 0;
                                netdev->tx_queue_len = 100;
-                               /* maybe add some timeout factor ? */
+                               adapter->tx_timeout_factor = 4;
                                break;
                        }
