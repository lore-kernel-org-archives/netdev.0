From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: RE: [Fwd: [E1000] NAPI re-insertion w/ changes]
Date: Tue, 1 Apr 2003 21:44:03 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16009.60419.764838.337501@robur.slu.se>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010107D314@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, Jason Lunz <lunz@falooley.org>,
   Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E010107D314@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Feldman, Scott writes:
 > >  Also still some concern by having the watchdog kicked in e1000_intr 
 > >  wouldn't e1000_clean feel better? 
 > 
 > e1000_intr feels better to me in keeping the clean-up work separate from
 > managing link status change (hopefully an infrequent event :).  Do you
 > see any problems?

 Well I was afraid that this would not be run at very heavy loads due to 
 interrupt disabling but I forgot:

e1000_watchdog(unsigned long data)
{      
    /* Cause software interrupt to ensure rx ring is cleaned */
    E1000_WRITE_REG(&adapter->hw, ICS, E1000_ICS_RXDMT0);

 
 Which generates irq from watchdog/timer so it should work and all practial 
 experiments indicates this is OK.

 Cheers.
						--ro
