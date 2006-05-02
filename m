From: Michal Schmidt <xschmi00@stud.feec.vutbr.cz>
Subject: Re: [PATCH] wireless/airo: minimal WPA awareness
Date: Tue, 02 May 2006 23:29:55 +0200
Message-ID: <4457CF53.7050000@stud.feec.vutbr.cz>
References: <1145118379.2324.18.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080404040306050307050404"
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	matthieu castet <castet.matthieu@free.fr>,
	Javier Achirica <achirica@telefonica.net>,
	Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tron.kn.vutbr.cz ([147.229.191.152]:4623 "EHLO tron.kn.vutbr.cz")
	by vger.kernel.org with ESMTP id S964987AbWEBVax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 May 2006 17:30:53 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1145118379.2324.18.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080404040306050307050404
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Dan Williams wrote:
> airo cards with firmware versions of 5.30.17 and higher support WPA.
> This patch recognizes WPA-capable firmware versions and adds support for
> retrieving the WPA and RSN information elements from the card's scan
> results.  The JOB and FLAG fields are now independent, since there was
> no space left in the FLAG field for FLAG_WPA_CAPABLE.
> 
> Signed-off-by: matthieu castet <castet.matthieu@free.fr>
> Signed-off-by: Dan Williams <dcbw@redhat.com>

Running Linux 2.6.17-rc3-mm1 which has this patch included I get this 
interesting message:
airo(eth0): WPA unsupported (only firmware versions 5.30.17 and greater 
support WPA.  Detected 5.30.17)

airo_test_wpa_capable assumes that the softSubVer part of the firmware 
version number is coded in BCD. Apparently, that's not true.
I have firmware version 5.30.17 and cap_rid.softSubVer is 0x11==17.

Signed-off-by: Michal Schmidt <xschmi00@stud.feec.vutbr.cz>

--------------080404040306050307050404
Content-Type: text/plain;
 name="airo-fix-firmware-version-compare.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="airo-fix-firmware-version-compare.diff"

diff -Nurp -X linux-mich/Documentation/dontdiff linux-mm/drivers/net/wireless/airo.c linux-mich/drivers/net/wireless/airo.c
--- linux-mm/drivers/net/wireless/airo.c	2006-05-02 20:20:37.000000000 +0200
+++ linux-mich/drivers/net/wireless/airo.c	2006-05-02 23:16:59.000000000 +0200
@@ -2768,7 +2768,7 @@ static int airo_test_wpa_capable(struct 
 
 	/* Only firmware versions 5.30.17 or better can do WPA */
 	if ((cap_rid.softVer > 0x530)
-	  || ((cap_rid.softVer == 0x530) && (cap_rid.softSubVer >= 0x17))) {
+	  || ((cap_rid.softVer == 0x530) && (cap_rid.softSubVer >= 17))) {
 		airo_print_info(name, "WPA is supported.");
 		return 1;
 	}

--------------080404040306050307050404--
