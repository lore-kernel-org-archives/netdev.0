From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: 3c59x (was Route cache performance under stress)
Date: Tue, 10 Jun 2003 18:45:03 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0306101815550.26879-100000@kenzo.iwr.uni-heidelberg.de>
References: <20030610.085600.71109220.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: sim@netnation.com, <ralph+d@istop.com>, <hadi@shell.cyberus.ca>,
   <xerox@foonet.net>, <fw@deneb.enyo.de>, <netdev@oss.sgi.com>,
   <linux-net@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030610.085600.71109220.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 10 Jun 2003, David S. Miller wrote:

> Unfortunately, NAPI won't help him with the current way the 3c59x
> driver works.  It needs to provide a way to use MEM I/O before NAPI
> would start to be of use to him.

I don't really want to sound like defending the 3c59x driver, but...
The 3c90x driver released by 3Com uses some mechanism "similar" to NAPI 
which is based on the on-board timer; these timer interrupts are scheduled 
dynamically. With this driver I would typically get TCP bandwidth figures 
4-5 Mbps lower than those obtained with 3c59x and noticable difference in 
the parallel jobs timing (using MPI over TCP). I'm not saying that NAPI 
will perform the same way, just that there might be also hardware limits 
somewhere...

But the real question is: does it make sense to spend time now in trying 
to improve a driver with hope for only a marginal speed increase ? After 
using these cards and the 3c59x driver with very good results for the past 
4 years, I'm looking for GigE replacements. Shouldn't anybody concerned 
with performance do the same ? Does it make sense to pair a very fast CPU 
and memory with a 33MHz-32bit PCI bus ?

And another important question: how much improvement can be gained from
the driver ? Folks that do parallel computation over TCP over Ethernet
know very well that the software in the kernel is the bottleneck (extra
copies, TCP, IRQ management, etc).  Packages that throw away TCP and use
another communication protocol can typically achieve much better ping-pong
times (they do have some other problems though) which shows that the
hardware and NIC driver are capable enough. So until I see a profile
showing that the CPU is spending most of the time in the driver, I won't
be convinced that these changes are needed....

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De
