From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: NAPI, e100, and system performance problem
Date: Sat, 23 Apr 2005 12:51:53 +1000
Message-ID: <20050423125153.65189ea0@localhost.localdomain>
References: <C925F8B43D79CC49ACD0601FB68FF50C03A633C7@orsmsx408>
	<Pine.LNX.4.61.0504180943290.15052@linux.site>
	<1113855967.7436.39.camel@localhost.localdomain>
	<20050419055535.GA12211@sgi.com>
	<m1hdhzyrdz.fsf@muc.de>
	<1114173195.7679.30.camel@localhost.localdomain>
	<20050422172108.GA10598@muc.de>
	<1114193902.7978.39.camel@localhost.localdomain>
	<20050422232831.GB6462@sgi.com>
	<20050423094038.72a8da73@localhost.localdomain>
	<20050422164301.724343f6.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: gnb@sgi.com, hadi@cyberus.ca, ak@muc.de, akepner@sgi.com,
        jesse.brandeburg@intel.com, netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050422164301.724343f6.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 22 Apr 2005 16:43:01 -0700
"David S. Miller" <davem@davemloft.net> wrote:

> On Sat, 23 Apr 2005 09:40:38 +1000
> Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> > My experience is that NAPI adds latency and that can cause worse performance.
> > I haven't seen a good analysis of the problem and/or simple tests to reproduce
> > the problem
> 
> Right, and it's cpu and bus speed dependant as to when you hit
> this bad case.  If your packet rate is perfectly such that
> only 1 or 2 packets get processed per interrupt then NAPI loses
> badly due to the extra PIO overhead entailed from enabling and
> disabling interrupts.
> 
> This is essential and well understood, and I personally don't need
> to see "numbers" to acknowledge this flaw.
> 
> I hope that minimal mitigation settings alleviate this problem for
> the most part.
> 
> When I moved tg3 over to NAPI, the happiest part of that was deleting
> the dynamic hw mitigation setting code the tg3 driver had.  If ever
> that kind of thing goes back into the drivers, it should be based
> upon a common feedback variable (something based upon dev->weight
> perhaps), not reimplemented N times, once in every driver.
> 
> With the dynamic schemes comes a new issue, how quickly to respond
> to changes in traffic patterns.

One of the problem with the dynamic schemes, is there is no generic infrastructure
to support it. There are some drivers that have tried dynamic schemes
but each seems to reinvent some adhoc scheme. Seems like a good area
for future research.

Another related problem is some drivers use NAPI for both TX and RX and
this can cause asymmetric behavior and scheduling issues. The whole
dev->weight limit stuff assumes RX not TX usage of NAPI
