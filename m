From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] [PATCH 1/3] netpoll api
Date: 03 Oct 2003 07:09:20 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1065179359.1031.42.camel@jzny.localdomain>
References: <20031003014104.GR1897@waste.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Andrew Morton <akpm@osdl.org>,
        Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20031003014104.GR1897@waste.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,


On Thu, 2003-10-02 at 21:41, Matt Mackall wrote:
> This patch implements a new netpoll API, which allows sending and
> receiving packets in context where interrupts may be disabled. It
> provides a common API for implementing features like netconsole,
> netdump/LKCD, and kgdb-over-ethernet and manages to isolate them
> almost completely from the details of the network layer.
> 

Nice.
Is the ethernet card in a case like this almost dedicated for this
kind of work?
Is disable_irq() in the controller safe for shared irqs? Or maybe this
is critical enough that you dont care?
Its a little wasteful to call the controller when there are is no work
to be done; we have found in NAPI that any extra PCI transactions cost.
(some IBM people doing benchmarking have complained about specweb not
looking good where NAPI will have one extra PCI transaction per packet.
You do it twice the rate NAPI would do it at low speeds).
Again, the answer maybe who cares, this is critical work.
Have you done any measurements to check whether it was worthwile to do
the skb preallocation? 

cheers,
jamal
