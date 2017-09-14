From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] netvsc: increase default receive buffer size
Date: Thu, 14 Sep 2017 10:49:05 -0700
Message-ID: <20170914104905.0145e489@plumbers-lap.home.lan>
References: <20170914163107.8404-1-sthemmin@microsoft.com>
 <20170914.100203.1656028222884493229.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, haiyangz@microsoft.com, sthemmin@microsoft.com,
 devel@linuxdriverproject.org
To: David Miller <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170914.100203.1656028222884493229.davem@davemloft.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Thu, 14 Sep 2017 10:02:03 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Thu, 14 Sep 2017 09:31:07 -0700
> 
> > The default receive buffer size was reduced by recent change
> > to a value which was appropriate for 10G and Windows Server 2016.
> > But the value is too small for full performance with 40G on Azure.
> > Increase the default back to maximum supported by host.
> > 
> > Fixes: 8b5327975ae1 ("netvsc: allow controlling send/recv buffer size")
> > Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>  
> 
> What other side effects are there to making this buffer so large?
> 
> Just curious...

It increase latency and exercises bufferbloat avoidance on TCP.
The problem was the smaller buffer caused regressions in UDP
benchmarks on 40G Azure. One could argue that this is not a reasonable
benchmark but people run it. Apparently, Windows already went
the same thing and uses an even bigger buffer.

Longer term there will be more internal discussion with different
teams about what the receive latency and buffering needs to be.
Also, the issue goes away when doing accelerated networking (SR-IOV)
is more widely used.
