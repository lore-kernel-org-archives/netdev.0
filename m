From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: Csum and csum copyroutines benchmark
Date: Fri, 25 Oct 2002 14:00:37 -0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200210251108.g9PB86p15344@Port.imtp.ilyichevsk.odessa.ua>
References: <200210231218.18733.roy@karlsbakk.net> <200210250906.g9P96Yp14775@Port.imtp.ilyichevsk.odessa.ua> <1035541191.12995.12.camel@irongate.swansea.linux.org.uk>
Reply-To: vda@port.imtp.ilyichevsk.odessa.ua
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: Momchil Velikov <velco@fadata.bg>, Russell King <rmk@arm.linux.org.uk>,
   Roy Sigurd Karlsbakk <roy@karlsbakk.net>, netdev@oss.sgi.com,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1035541191.12995.12.camel@irongate.swansea.linux.org.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 25 October 2002 08:19, Alan Cox wrote:
> On Fri, 2002-10-25 at 14:59, Denis Vlasenko wrote:
> > Well, that makes it run entirely in L0 cache. This is unrealistic
> > for actual use. movntq is x3 faster when you hit RAM instead of L0.
> >
> > You need to be more clever than that - generate pseudo-random
> > offsets in large buffer and run on ~1K pieces of that buffer.
>
> In a lot of cases its extremely realistic to assume the network
> buffers are in cache. The copy/csum path is often touching just
> generated data, or data we just accessed via read(). The csum RX path
> from a card with DMA is probably somewhat different.

'Touching' is not interesting since it will pump data
into cache, no matter how you 'touch' it.

Running benchmarks against 1K static buffer makes cache red hot
and causes _all writes_ to hit it. It may lead to wrong conclusions. 

Is _dst_ buffer of csum_copy going to be used by processor soon?
If yes, we shouldn't use movntq, we want to cache dst.
If no, we should by all means use movntq.
If sometimes, then optimal strategy does not exist. :(
--
vda
