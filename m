From: Karlis Peisenieks <karlis@mt.lv>
Subject: Re: IFF_NOARP & broadcasting [2]
Date: Thu, 25 Jul 2002 17:53:10 +0300
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020725175310.A13694@karlis>
References: <20020725163223.A13299@karlis> <200207251402.SAA02033@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200207251402.SAA02033@sex.inr.ac.ru>; from kuznet@ms2.inr.ac.ru on Thu, Jul 25, 2002 at 17:02:18 +0300
List-Id: netdev.vger.kernel.org

On 2002.07.25 17:02 kuznet@ms2.inr.ac.ru wrote:

> You have just made great discovery. :-)
> 
> It was big puzzle why people blame that they see packets with zero MAC,
> sometimes. Apparently, this happens on the first packet, when hh cache
> is still not created. :-)

Yes, this was killing me too.

> I am not sure that this is right. Protocols using neighbour cache
> will work, but anothers will fail on NOARP devices.
> 
> It is safer just to reorder two ifs, checking for daddr!=NULL first.

You mean like this:

--- eth.c.orig	Thu Jul 25 17:50:20 2002
+++ eth.c	Thu Jul 25 17:50:35 2002
@@ -96,6 +96,12 @@
 	else
 		memcpy(eth->h_source,dev->dev_addr,dev->addr_len);
 
+	if(daddr)
+	{
+		memcpy(eth->h_dest,daddr,dev->addr_len);
+		return dev->hard_header_len;
+	}
+	
 	/*
 	 *	Anyway, the loopback-device should never use this
function... 
 	 */
@@ -106,12 +112,6 @@
 		return(dev->hard_header_len);
 	}
 	
-	if(daddr)
-	{
-		memcpy(eth->h_dest,daddr,dev->addr_len);
-		return dev->hard_header_len;
-	}
-	
 	return -dev->hard_header_len;
 }
 

Karlis
