From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: RE: e1000 close (NAPI)
Date: Wed, 8 Oct 2003 11:16:02 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16259.54738.75122.134408@robur.slu.se>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0102229702@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Robert Olsson" <Robert.Olsson@data.slu.se>,
        "Jeff Garzik" <jgarzik@pobox.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E0102229702@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Feldman, Scott writes:
 > > -	if(work_done < work_to_do) {
 > > +	if(work_done < work_to_do || !netif_running(netdev)) {
 > >  		netif_rx_complete(netdev);
 > >  		e1000_irq_enable(adapter);
 > >  	}
 > 
 > Is e1000 unique in this regard, or do the other NAPI-enabled drivers
 > have the same issue?

 Hello!

 Other drivers may have the same issue. This was spotted while stress-testing 
 tulip. Patch was sent here some days ago. It's only seen if trying to close 
 device under extreme loads. See the syncing code in dev_close()

 You may try the e100 as well. We update the docs when see that this is OK.

 Cheers.
						--ro
