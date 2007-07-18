From: Patrick McHardy <kaber@trash.net>
Subject: Re: tc filter add ... fw ... action drop
Date: Wed, 18 Jul 2007 12:46:20 +0200
Message-ID: <469DEF7C.8040709@trash.net>
References: <20070718032841.GA14874@toroid.org> <469DE243.20903@trash.net> <20070718102716.GA32421@toroid.org> <469DEB9A.9020606@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010800010709020608080908"
Cc: Abhijit Menon-Sen <ams@toroid.org>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35063 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753527AbXGRKqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 06:46:46 -0400
In-Reply-To: <469DEB9A.9020606@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010800010709020608080908
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Abhijit Menon-Sen wrote:
> 
>>That command is from a script that used to work with iproute2-ss020116
>>(2002!), which had the following in tc/m_police.c:
>>
>>210     } else if (strcmp(*argv, "action") == 0) {
>>211             NEXT_ARG();
>>212             if (get_police_result(&p.action, &presult, *argv)) {
>>
>>I don't know when that bit was dropped, but it used to be there. :-)
> 
> 
> 
> Indeed, I missed that. I'll fix up the patch ..


OK this patch fixes parsing of "action ...". I've removed
the erroring on unknown arguments again since in that case
the caller should continue parsing.


--------------010800010709020608080908
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/tc/m_police.c b/tc/m_police.c
index 36a7719..76cdbe1 100644
--- a/tc/m_police.c
+++ b/tc/m_police.c
@@ -227,7 +227,8 @@ int act_parse_police(struct action_util *a,int *argc_p, char ***argv_p, int tca_
 			p.action = TC_POLICE_OK;
 		} else if (matches(*argv, "pipe") == 0) {
 			p.action = TC_POLICE_PIPE;
-		} else if (strcmp(*argv, "conform-exceed") == 0) {
+		} else if (strcmp(*argv, "action") == 0 ||
+			   strcmp(*argv, "conform-exceed") == 0) {
 			NEXT_ARG();
 			if (get_police_result(&p.action, &presult, *argv)) {
 				fprintf(stderr, "Illegal \"action\"\n");

--------------010800010709020608080908--
