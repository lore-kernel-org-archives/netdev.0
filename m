From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: 2.6.2 crash after network link failure
Date: Mon, 9 Feb 2004 15:37:48 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDE6C@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "David S. Miller" <davem@redhat.com>,
        "Petr Vandrovec" <vandrove@vc.cvut.cz>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> I think what might be happening is that somehow the TX queue 
> is corrupted if
> e100_config() runs (due to link UP state change) while there 
> are active normal SKB packets on the TX queue.  Or perhaps 
> some TX queue handling locking issue.
> 
> Scott, any ideas?

e100 hardware will continue to process the hardware's Tx queue even
after link is lost, and then cleanup (return skbs) on interrupt.  I
would expect e100 to be holding no Tx skbs when link returned.

Petr, -mm kernel has an updated (and much simpler) e100 driver.  Is this
something you can try?  The switch failure can be simulated by manually
plugging the cable in/out.

-scott
