From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6] tc: report informations for multiqueue devices
Date: Wed, 02 Sep 2009 15:18:05 +0200
Message-ID: <4A9E708D.5040806@trash.net>
References: <20090902081429.GB4878@ff.dom.local>	<4A9E2CC7.1010103@gmail.com> <20090902.013002.181288977.davem@davemloft.net> <4A9E6551.4030209@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jarkao2@gmail.com,
	cl@linux-foundation.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46261 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751955AbZIBNSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 09:18:10 -0400
In-Reply-To: <4A9E6551.4030209@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> [PATCH net-next-2.6] tc: report informations for multiqueue devices
> 
> qdisc and classes are not yet displayed by "tc -s -d {qdisc|class} show"
> for multiqueue devices.
> 
> We use a new TCA_QINDEX attribute, to report queue index to user space.
> iproute2 tc should be changed to eventually display this queue index as in :
> 
> $ tc -s -d qdisc
> qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>  Sent 52498 bytes 465 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 0bit 0pps backlog 0b 0p requeues 0
> qdisc pfifo_fast 0: dev eth0 qindex 1 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 0bit 0pps backlog 0b 0p requeues 0

This might confuse existing userspace since the handle is not unique
anymore. libnl f.i. will treat all but the first root qdisc as an
update and use it to update the state of the first one. There's also
no combined view for applications unaware of multiqueue.

Please have a look at the mail I just wrote for some possible ways
around this.
