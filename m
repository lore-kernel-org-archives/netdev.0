From: Andrew Morton <akpm@digeo.com>
Subject: Re: patch for common networking error messages
Date: Tue, 17 Jun 2003 00:20:27 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030617002027.00c96c7a.akpm@digeo.com>
References: <3EEE28DE.6040808@us.ibm.com>
	<20030616.133841.35533284.davem@redhat.com>
	<20030616205342.GH30400@wotan.suse.de>
	<20030616.135124.71580008.davem@redhat.com>
	<20030616152707.58da808c.akpm@digeo.com>
	<20030617070957.GB2752@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, ak@suse.de, janiceg@us.ibm.com,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
	stekloff@us.ibm.com, girouard@us.ibm.com, lkessler@us.ibm.com,
	kenistonj@us.ibm.com, jgarzik@pobox.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20030617070957.GB2752@wotan.suse.de>
List-Id: netdev.vger.kernel.org

Andi Kleen <ak@suse.de> wrote:
>
> > Actually it already does, to cover the case where an interrupt handler calls
> > printk while process-context code is performing a printk.
> 
> I don't think it'll work. Both printk and release_console_sem take the logbuf_lock,
> which will deadlock if the same CPU already holds it.

Look more closely.

logbuf_lock is only held to protect the logbuf contents and its indices. 
And to pin down the current console_sem holder to reliably ensure that
he'll print the text which the nested printer just placed in the buffer.

We do not call the console drivers while holding logbuf_lock.  console_sem
is held across the console driver call.
