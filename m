From: Andi Kleen <ak@suse.de>
Subject: Re: patch for common networking error messages
Date: Tue, 17 Jun 2003 09:09:57 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030617070957.GB2752@wotan.suse.de>
References: <3EEE28DE.6040808@us.ibm.com> <20030616.133841.35533284.davem@redhat.com> <20030616205342.GH30400@wotan.suse.de> <20030616.135124.71580008.davem@redhat.com> <20030616152707.58da808c.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, ak@suse.de, janiceg@us.ibm.com,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com, stekloff@us.ibm.com,
   girouard@us.ibm.com, lkessler@us.ibm.com, kenistonj@us.ibm.com,
   jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@digeo.com>
Content-Disposition: inline
In-Reply-To: <20030616152707.58da808c.akpm@digeo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Actually it already does, to cover the case where an interrupt handler calls
> printk while process-context code is performing a printk.

I don't think it'll work. Both printk and release_console_sem take the logbuf_lock,
which will deadlock if the same CPU already holds it.

It would need to use the usual linux recursive lock hack.

-Andi
