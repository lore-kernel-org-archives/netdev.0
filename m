From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Wed, 12 Jan 2005 20:27:40 +0100
Message-ID: <16869.31276.256679.96845@robur.slu.se>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain>
	<200501111927.15574.jeremy.guthrie@berbee.com>
	<16869.15931.324875.264756@robur.slu.se>
	<200501121025.03899.jeremy.guthrie@berbee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>,
        Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jeremy.guthrie@berbee.com
In-Reply-To: <200501121025.03899.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jeremy M. Guthrie writes:

 > >  > ETH3 Interrupts(calc'd from below):  1479968

 > >  Very strange...
 > >
 > >  eth3 is bound to CPU0 which in turn has all packet load... If we were
 > >  to believe your CPU0 was saturated (due to the drops). We should see no
 > >  (RX) interrupts on eth3. But there is a lot... one irq per every three
 > >  packet. Why?

 > I have no idea why it would be doing this.

 Huh seems you didn't add the patch I sent. Below is diff from my editor to your
 e1000_main.c

							--ro


--- e1000_main.c.jmg	2005-01-12 20:14:08.324168072 +0100
+++ e1000_main.c	2005-01-12 20:17:24.777302656 +0100
@@ -2264,14 +2264,13 @@
 	netdev->quota -= work_done;
 	
 	/* if no Rx and Tx cleanup work was done, exit the polling mode */
-	if(!tx_cleaned || (work_done < work_to_do) || 
-				!netif_running(netdev)) {
+	 if( (!tx_cleaned && (work_done == 0)) || !netif_running(netdev)) {
 quit_polling:	netif_rx_complete(netdev);
 		e1000_irq_enable(adapter);
 		return 0;
 	}
 
-	return (work_done >= work_to_do);
+	return 1;
 }
 
 #endif
