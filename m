From: "John Ye" <johny@asimco.com.cn>
Subject: Re: [PATCH: 2.6.13-15-SMP 3/3] network: concurrentlyrunsoftirqnetwork code on SMP
Date: Wed, 26 Sep 2007 10:12:40 +0800
Message-ID: <004d01c7ffe2$b73fec20$ca8510ac@asimco>
References: <004901c7fd9c$94370df0$d6ddfea9@JOHNYE1> <1190551422.4256.36.camel@localhost> <007201c7ff89$d5db4cf0$d6ddfea9@JOHNYE1> <20070925090333.11beebb2@freepuppy.rosehill> <1190758944.4244.23.camel@localhost>
Cc: "David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<kuznet@ms2.inr.ac.ru>, <pekkas@netcore.fi>, <jmorris@namei.org>,
	<kaber@coreworks.de>, <iceburgue@gmail.com>
To: <hadi@cyberus.ca>,
	"Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.asimco-na.com ([207.138.153.195]:42329 "EHLO
	mail.asimco-na.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753567AbXIZCKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2007 22:10:31 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jamal & Stephen,

I found BSS-hash paper you mentioned and have browsed it briefly.
The issue "may end sending all your packets to one cpu" might be dealt with
by
cpu hash (srcip + dstip) % nr_cpus, plus checking cpu balance periodically,
shift cpu by an extra seed value?

Any way, the cpu hash code must not be too expensive because every incoming
packet hits the path.

We are going to do further study on this BSS thing.

__do_IRQ has a tendency to collect same IRQ on different CPUs into one CPU
when NIC is busy(by IRQ_PENDING & IRQ_INPROGRESS control skill). so,
dispatch the load to SMP here may be good thing(?).

Thanks.

John Ye


----- Original Message -----
From: "jamal" <hadi@cyberus.ca>
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Cc: "john ye" <johny@asimco.com.cn>; "David Miller" <davem@davemloft.net>;
<netdev@vger.kernel.org>; <kuznet@ms2.inr.ac.ru>; <pekkas@netcore.fi>;
<jmorris@namei.org>; <kaber@coreworks.de>; <iceburgue@gmail.com>
Sent: Wednesday, September 26, 2007 6:22 AM
Subject: Re: [PATCH: 2.6.13-15-SMP 3/3] network:
concurrentlyrunsoftirqnetwork code on SMP


> On Tue, 2007-25-09 at 09:03 -0700, Stephen Hemminger wrote:
>
> > There is a standard hash called RSS, that many drivers support because
it is
> > used by other operating systems.
>
> I think any stateless/simple thing will do (something along the lines
> what 802.1ad does for trunk, a 5 classical five tuple etc).
>
> Having solved the reordering problem in such a stateless way introduces
> a loadbalancing setback; you may end sending all your packets to one cpu
> (a problem Mr Ye didnt have when he was re-orderding ;->).
>
> cheers,
> jamal
>
>


