From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: [net-next-2.6 PATCH] net: fast consecutive name allocation
Date: Sun, 15 Nov 2009 09:06:04 +1030
Message-ID: <20091115090604.331d75c2@opy.nosense.org>
References: <20091113233504.GQ19478@kvack.org>
	<20091113153924.6130135f@nehalam>
	<20091113235210.GR19478@kvack.org>
	<20091113.185937.251557071.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bcrl@lhnet.ca, shemminger@vyatta.com, opurdila@ixiacom.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.adam.net.au ([202.136.110.247]:43186 "EHLO
	smtp4.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751109AbZKNWgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Nov 2009 17:36:12 -0500
In-Reply-To: <20091113.185937.251557071.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Nov 2009 18:59:37 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Benjamin LaHaise <bcrl@lhnet.ca>
> Date: Fri, 13 Nov 2009 18:52:10 -0500
> 
> > If you don't want the overhead from this kind of scaling, stick it under a 
> > config option, but please don't stop other people from pushing Linux into 
> > new uses which have these scaling requirements.
> 
> This 'scaling requirement' only exists in environments where people
> undersubsribe their networks, right?
> 
> I'm not saying we won't put scaling into these areas, I'm just trying
> to make a point to show that this "need" only exists because people
> have purposefully created these situations where they feel the need to
> massively control their users usage in order to generate revenue.

I'm don't understand that comment, and I work for (and
designed most of the infrastructure for) an ISP that usually has
well over 40 000 concurrent PPPoE sesssions at any one time.

The fundamental purpose of PPPoE is nothing to do with any scaling or
architecture, it is purely to make a more modern shared networking
technology like Ethernet look like high speed dial up. This has occurred
mainly because when broadband came along it allowed ISPs to introduce
it quickly, without having to also upgrade their dial up oriented
backend systems i.e. customer authentication/accounting and customer
support systems. It wasn't ideal then and it isn't ideal now. PPPoE adds
an overhead of 8 bytes per packet, yet the only thing it is doing is
changing ethernet from multipoint to point-to-point so PPP can run
over it and providing ISPs with an ability to identify the subscriber.
There are other methods to solve customer identity problem without the
PPPoE overheads. Moving to them however can be a long drawn out process
because it also means changes to customer's CPE settings, or running
the old and new methods in parallel for the foreseeable future.

On the occasions I've looked at whether a Linux box would be an
alternative to the Cisco BRAS platform we use, the last time I looked
the number of sessions people were saying they were running was
500. I don't consider Linux to be feasible in that role until you're
able to run at least 5000 sessions on a single box. I'm a bit unusual
in that regard, as I prefer the "lots of smaller, increase chances
of failure, but consequences of failure" model - you manage the
larger number of them via configuration templating / scripted
change deployment. You need to chose your subscriber per device level,
and if 500 is the current limit for Linux, then in my opinion it is
currently too low for my application. Others in the industry might
consider 5000 too low, as they are running devices that can handle 32
000 or 64 000 PPPoE sessions.



> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
