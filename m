From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: e100 "Ferguson" release
Date: Tue, 5 Aug 2003 08:19:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E01022292A4@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "Jeff Garzik" <jgarzik@pobox.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Felix Radensky" <felix@allot.com>, "Ben Greear" <greearb@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> I've also noticed that the number of hard_start_xmit failures 
> in e1000 has increased significantly in version 5.1.13-k1. In 
> version 5.0.43-k1 the number of failures was much smaller.

Interesting.  Felix, would you undo the change[1] below in 5.1.13-k1 and
see what happens?  With the change below, 5.1.13 would be more
aggressive on Tx cleanup, so we'll be quicker waking the queue than
before. 

-scott

        for(i = 0; i < E1000_MAX_INTR; i++)
-               if(!e1000_clean_rx_irq(adapter) &&
+               if(!e1000_clean_rx_irq(adapter) &
                   !e1000_clean_tx_irq(adapter))
                        break;

[1] Something still bothers me about this new form where we're mixing a
bit-wise operator with logical operands.  Should this bother me?
