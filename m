From: James Morris <jmorris@intercode.com.au>
Subject: Re: [PATCH] [1/2] kernel error reporting (revised)
Date: Sun, 20 Jul 2003 09:52:33 +1000 (EST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <Mutt.LNX.4.44.0307200951210.21994-100000@excalibur.intercode.com.au>
References: <3F1882CF.538FE76@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@osdl.org>, <davem@redhat.com>,
	<linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>,
	<jgarzik@pobox.com>, <alan@lxorguk.ukuu.org.uk>,
	<rddunlap@osdl.org>, <kuznet@ms2.inr.ac.ru>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Jim Keniston <jkenisto@us.ibm.com>
In-Reply-To: <3F1882CF.538FE76@us.ibm.com>
List-Id: netdev.vger.kernel.org

On Fri, 18 Jul 2003, Jim Keniston wrote:

> > Yes, this makes sense.  At the kerror.c level, just return -EDEADLK if in_irq().
> > Delay packet delivery (via a tasklet, as before) at the evlog.c level instead.
> > That way, we know at the evlog.c level (in the tasklet) whether the event packet
> > was delivered to anybody, and can paraphrase it to printk if it wasn't.
> >
> > Is this the sort of thing you had in mind?

Not exactly -- I don't think the logging framework should do any irq 
detection.  The caller should either know if its in an interrupt, or do 
the detection itself.


- James
-- 
James Morris
<jmorris@intercode.com.au>
