From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Csum and csum copyroutines benchmark
Date: 25 Oct 2002 11:19:51 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1035541191.12995.12.camel@irongate.swansea.linux.org.uk>
References: <200210231218.18733.roy@karlsbakk.net>
	<200210250643.g9P6hop13980@Port.imtp.ilyichevsk.odessa.ua>
	<87n0p3x8lh.fsf@fadata.bg>
	<200210250906.g9P96Yp14775@Port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Momchil Velikov <velco@fadata.bg>, Russell King <rmk@arm.linux.org.uk>,
   Roy Sigurd Karlsbakk
	 <roy@karlsbakk.net>, netdev@oss.sgi.com,
   Linux Kernel Mailing List
	 <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: vda@port.imtp.ilyichevsk.odessa.ua
In-Reply-To: <200210250906.g9P96Yp14775@Port.imtp.ilyichevsk.odessa.ua>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2002-10-25 at 14:59, Denis Vlasenko wrote:
> Well, that makes it run entirely in L0 cache. This is unrealistic
> for actual use. movntq is x3 faster when you hit RAM instead of L0.
> 
> You need to be more clever than that - generate pseudo-random
> offsets in large buffer and run on ~1K pieces of that buffer.

In a lot of cases its extremely realistic to assume the network buffers
are in cache. The copy/csum path is often touching just generated data,
or data we just accessed via read(). The csum RX path from a card with
DMA is probably somewhat different.
