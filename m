From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] Make possible speeds known to ethtool
Date: Thu, 08 Jan 2009 11:50:03 -0800
Message-ID: <496658EB.1080206@hp.com>
References: <200901080203.SAA19103@tardy.cup.hp.com>	<1231384446.2677.32.camel@hashbaz.i.decadent.org.uk>	<49656F01.3090603@pobox.com>  <49664FFD.1010608@hp.com> <1231442701.3893.4.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:2483 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752507AbZAHTuJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 14:50:09 -0500
In-Reply-To: <1231442701.3893.4.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 
> I think 0, (u32)(-1) and (u16)(-1) may have to be special-cased as
> unknown, but everything else can be treated as a number of Mbit/s.  I
> don't know what a driver should do about an interface that really runs
> at 65.535 Gbit/s though...

Something along these lines then? (assuming my mailer doesn't fubar this
:( - I normally send matches via mailx)

--- ethtool.c.orig      2008-11-17 11:53:40.000000000 -0800
+++ ethtool.c   2009-01-08 11:41:54.000000000 -0800
@@ -813,23 +813,12 @@ static int dump_ecmd(struct ethtool_cmd

         fprintf(stdout, "       Speed: ");
         switch (ep->speed) {
-       case SPEED_10:
-               fprintf(stdout, "10Mb/s\n");
-               break;
-       case SPEED_100:
-               fprintf(stdout, "100Mb/s\n");
-               break;
-       case SPEED_1000:
-               fprintf(stdout, "1000Mb/s\n");
-               break;
-       case SPEED_2500:
-               fprintf(stdout, "2500Mb/s\n");
-               break;
-       case SPEED_10000:
-               fprintf(stdout, "10000Mb/s\n");
+       case 0:
+       case (u16)(-1):
+               fprintf(stdout, "Unknown! (%i)\n", ep->speed);
                 break;
         default:
-               fprintf(stdout, "Unknown! (%i)\n", ep->speed);
+               fprintf(stdout, "%dMb/s\n", ep->speed);
                 break;
         };

If that looks reasonable I'll post a proper one with the apropriate text and such with mailx...

rick jones
