From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: [PATCH net-next] bnx2x: Add Nic partitioning mode (57712 devices)
Date: Mon, 06 Dec 2010 10:21:50 -0800
Message-ID: <4CFD29BE.2060201@chelsio.com>
References: <1290982177.6066.3.camel@lb-tlvb-dmitry> <20101129060114.GC29904@auslistsprd01.us.dell.com> <1291023192.9770.0.camel@lb-tlvb-eilong.il.broadcom.com> <20101206173534.GC13628@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eilon Greenstein <eilong@broadcom.com>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"narendra_k@dell.com" <narendra_k@dell.com>,
	"jordan_hargrave@dell.com" <jordan_hargrave@dell.com>
To: Matt Domsch <Matt_Domsch@dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:31285 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753539Ab0LFSV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 13:21:59 -0500
In-Reply-To: <20101206173534.GC13628@auslistsprd01.us.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matt Domsch wrote:
> For SR-IOV, biosdevname follows the physfn and virtfn* pointers to map
> VFs to the PF.

This gives the PF a VF maps to but in general doesn't say anything about the 
port the VF maps to, unless you make additional assumptions as below.

> But it assumes 1 PF -> 1 port.  For the Intel 1GbE and
> 10GbE cards I have, this is true, but nothing says it has to be true.

Yes, there are devices for which this isn't true.  You can have several PFs 
mapping to 1 port, 1 PF mapping to several ports, a PF mapping to some 
port(s) but its VFs mapping to different port(s), ...

> Maybe something like:
> 
> /sys/class/net_port/<port_name>/<ifname> -> /sys/class/net/<ifname>
> 
> /sys/class/net/<ifname>/port -> /sys/class/net_port/<port_name>
> 
> This introduces the idea of ports, though adds the complication of
> needing to name them somehow.  But it would expose the relationship of
> each net interface to a specific port, as well as allow multiple
> interfaces per port, conceptually independent of the PCI device
> mapping.  That way, each driver, which must know the mapping somehow,
> could fill these links out?

/sys/class/net/<ifname>/dev_id indicates the physical port <ifname> is 
associated with.  At least a few drivers set up dev_id this way.

