From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] netpoll: allow execution of multiple rx_hooks per
 interface
Date: Wed, 06 Jan 2010 21:54:05 -0600
Message-ID: <1262836445.29868.227.camel@calx>
References: <4B44F895.9080205@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Jeff Moyer <jmoyer@redhat.com>,
	netdev@vger.kernel.org, netdev@oss.sgi.com,
	David Miller <davem@davemloft.net>
To: Daniel Borkmann <danborkmann@googlemail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932835Ab0AGDyT@vger.kernel.org>
In-Reply-To: <4B44F895.9080205@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-01-06 at 21:54 +0100, Daniel Borkmann wrote:
> Hi,
> 
> this patch allows the registration and _execution_ of multiple netpoll
> rx_hooks per interface. Currently, it is possible to register multiple
> netpoll structures to one interface, _but_ only one single rx_hook (from
> the netpoll struct that has been registered last) can be executed, which
> was an oversight in the implementation [1].
> So, this patch fixes it. I've sucessfully tested it within 2.6.32.2 with
> the registration of multiple rx_hook clients for several times. I'd
> appreciate comments / feedback.

(grumbles about cc:)

Please inline patches so they can be reviewed easily in reply.


-       struct netpoll *np = npi->rx_np;
+       struct netpoll **np = &npi->rx_np;
 
-       if (!np)
+       if (!(*np))

This makes everything horrible. Can you avoid the double indirection?
Using a list head might be a good answer.

-- 
http://selenic.com : development and support for Mercurial and Linux
