From: Cheng Jin <chengjin@cs.caltech.edu>
Subject: Re: Linux SMP on 2.4.18-3
Date: Mon, 28 Oct 2002 10:26:58 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33L0.0210281020180.28869-100000@fast2.cs.caltech.edu>
References: <Pine.GSO.4.30.0210280741020.9849-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <Pine.GSO.4.30.0210280741020.9849-100000@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jamal,

Thanks for writing me back.

> The IP network stack in linux is totaly reentrant. You could have a
> packet on _each_ processor in SMP concurently executing the same code. If
> you add anything, you need to take this into account.

We did add code to the TCP layer, but I don't exactly see anything in the
original code where locking is used.  I assume the locks are in the IP
layer and lower?  The weirdest thing is that we noticed in
update_send_head, tp->packets_out sometimes increases by more than one
even though the code ++ it only once.  I guess I am not sure how we could
have screwed it up if the modifications are on the TCP layer.

> In non-NAPI based NICs such as yours, you could have reordering within
> the system (this is described in the NAPI paper). Either get it NAPIfied
> or get yourself a NAPI capable NIC such as tg3 based, e1000, Dlink gige
> etc.

Out of curiosity, what is the maximum send rate (pps) under Linux
2.4.18-3?  I read in the paper that sending across two Intel Gbe with one
CPU gets up to 36o Kpps.


Thanks,

Cheng
