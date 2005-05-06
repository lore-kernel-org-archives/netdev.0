From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: 3c509 module and 2.6 kernel: not all NICs are recognized?
Date: Sat, 07 May 2005 01:59:28 +0400
Message-ID: <427BE8C0.3090108@tls.msk.ru>
References: <427BD143.4010909@tls.msk.ru> <427BDD22.1080601@tls.msk.ru> <427BE3A0.7010000@didntduck.org> <427BE47B.303@tls.msk.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050500020904080408090206"
Cc: Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <427BE47B.303@tls.msk.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050500020904080408090206
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Michael Tokarev wrote:
> Brian Gerst wrote:
> 
>>Michael Tokarev wrote:
> 
> []
> 
>>>>It have 4 3c509 cards, one EISA and 3 ISA.  Here's the dmesg
> 
> []
> 
>>>All the ISA cards are in EISA mode (set in 3c5x9cfg.exe utility).
>>>IRQs are assigned by the EISA bus (set by EISA configuration utility).
>>>If any of the ISA cards are in non-EISA mode, the some of them
>>>does not work at all, starting from EISA BIOS config during boot.
>>>So I can't switch the cards into PNP mode.
> 
> []
> 
>>what does dmesg|grep EISA show?
> 
> 
> Looks like I already found it by looking at the driver source.
> 
> struct eisa_device_id el3_eisa_ids[] = {
>                 { "TCM5092" },
>                 { "TCM5093" },
>                 { "TCM5095" },     <==== I added this line
>                 { "" }
> };
> 
> and now it works.
> 
> EISA: Probing bus 0 at 0000:00:06.0
> EISA: Mainboard ACR1C01 detected.
> EISA: slot 2 : TCM5095 detected.
> EISA: slot 3 : TCM5095 detected.
> EISA: slot 4 : TCM5095 detected.
> EISA: slot 5 : TCM5093 detected.
> EISA: Detected 4 cards.
> 
> 
> I'm not sure if it will work with ISA cards in ISA mode.
> As I pointed out above, this machine does not want to
> initialize EISA bus if at least one of the cards isn't
> in EISA mode.  Will "plain" (in ISA mode) 3c509 be shown
> in EISA scan too?

The trivial patch is attached.  Please consider applying.

/mjt

--------------050500020904080408090206
Content-Type: text/plain;
 name="3c509-ISA-in-EISA-mode.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="3c509-ISA-in-EISA-mode.patch"

This trivial patch adds support for ISA 3c509 cards in EISA mode.

Signed-Off-By: Michael Tokarev <mjt@tls.msk.ru>

--- a/drivers/net/3c509.c.orig	Sat May  7 01:55:35 2005
+++ b/drivers/net/3c509.c	Sat May  7 01:27:49 2005
@@ -217,6 +217,7 @@
 struct eisa_device_id el3_eisa_ids[] = {
 		{ "TCM5092" },
 		{ "TCM5093" },
+		{ "TCM5095" },
 		{ "" }
 };
 

--------------050500020904080408090206--
