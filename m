From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bnx2/5709: Strange interrupts spread
Date: Fri, 2 Jul 2010 13:58:31 -0700
Message-ID: <1278104311.11828.12.camel@HP1>
References: <AANLkTiniNNPV9ztxXHtX4np7PIZabkm0I4v5O29chf8i@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Christophe Ngo Van Duc" <cngovanduc@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4942 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754533Ab0GBU7Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jul 2010 16:59:16 -0400
In-Reply-To: <AANLkTiniNNPV9ztxXHtX4np7PIZabkm0I4v5O29chf8i@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2010-07-02 at 13:33 -0700, Christophe Ngo Van Duc wrote:
> On eth2 (external card) all interrupts goes to CPU0
>
>
>            CPU0       CPU1       CPU2       CPU3       CPU4       CPU5       CPU6       CPU7
>   80:   46973077          0          0          0          0          0          0          0   PCI-MSI-edge      eth2-0
>   81:          0          0          0          0          0          0          0          0   PCI-MSI-edge      eth2-1
>   82:          0          0          0          0          0          0          0          0   PCI-MSI-edge      eth2-2
>   83:          0          0          0          0          0          0          0          0   PCI-MSI-edge      eth2-3
>   84:          0          0          0          0          0          0          0          0   PCI-MSI-edge      eth2-4
>   85:          0          0          0          0          0          0          0          0   PCI-MSI-edge      eth2-5
>   86:          0          0       2445          0         37          0       8463         13   PCI-MSI-edge      eth2-6
>   87:          0          0          0          0          0          0          0          0   PCI-MSI-edge      eth2-7

Reformatted your output

> If I understand correctly the RSS hash is used to dispatch the packets
> into the different queues running on the different CPU.

It looks like most interrupts go to eth2-0, a few go to eth2-6.  The rx
ring for eth2-0 is for non-IP packets.  The RSS hash will hash IP
packets and place them on eth2-1 to eth2-7.  eth2-0 also handles tx
interrupts for TX ring 0.  TX traffic is hashed by the stack.

What kind of traffic is passing through eth2?

Thanks.


