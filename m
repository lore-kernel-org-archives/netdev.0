From: Paul Mackerras <paulus@samba.org>
Subject: spin_lock_bh() called in irq handler
Date: Wed, 28 Apr 2004 17:24:14 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16527.23582.316697.56419@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-tr@linuxtr.net
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

We're hitting a bug with the olympic token-ring driver where the
driver gets a receive interrupt and calls tr_type_trans.  That calls
tr_add_rif_info() which does spin_lock_bh().  On our iSeries systems
that triggers a BUG() check.  Which is reasonable, since using
spin_lock_bh() to protect a data structure, and then calling a
function that modifies that data structure within an interrupt
handler, is clearly a bug.

I had a look and found that all of the token-ring drivers call
tr_type_trans() at interrupt level.  That seems perfectly reasonable
to me.  To fix the bug, it seems to me that there are two options:
either move the tr_add_rif_info() call elsewhere (but I have no idea
where) or else use spin_lock_irqsave instead of spin_lock_bh.

Which is the more appropriate fix?

Thanks,
Paul.
