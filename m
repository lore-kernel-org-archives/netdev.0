From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net v2] L2TP:Adjust intf MTU,factor underlay L3,overlay
 L2
Date: Thu, 29 Sep 2016 14:21:55 +0200
Message-ID: <20160929142155.49f9cf0a@griffin>
References: <alpine.DEB.2.11.1609221341500.6975@duvvury30.eng.vyatta.net>
        <20160927.033153.1066118008027608891.davem@davemloft.net>
        <alpine.DEB.2.11.1609271210350.25517@duvvury48.eng.vyatta.net>
        <20160928.034841.997752666320557327.davem@davemloft.net>
        <alpine.DEB.2.11.1609281857050.17015@duvvury48.eng.vyatta.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kleptog@svana.org,
        jchapman@katalix.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, nprachan@brocade.com,
        rshearma@brocade.com, dfawcus@brocade.com,
        stephen@networkplumber.org, acme@redhat.com, lboccass@brocade.com
To: "R. Parameswaran" <parameswaran.r7@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46864 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755432AbcI2MWB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Sep 2016 08:22:01 -0400
In-Reply-To: <alpine.DEB.2.11.1609281857050.17015@duvvury48.eng.vyatta.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Sep 2016 19:36:45 -0700 (PDT), R. Parameswaran wrote:
> I'd like to point out one difference with VXLAN - in VXLAN, the 
> local physical interface is directly specified at the time of 
> creation of the tunnel, and the data structure seems to have the ifindex 
> of the local interface with which it is able to directly pull up the 
> underlay interface device. Whereas in L2TP, we only have the IP
> address of the remote tunnel end-point and thus only the socket and the 
> dst from which we need to derive this. 

Strictly speaking, VXLAN *may* know the underlying interface. It can
also be set up with just local and remote IP address, or even worse, in
metadata mode where we don't know the address nor the interface until
we get a packet (and each packet may have those different).

MTU wise, those cases are not accommodated for in the kernel. The vxlan
interface gets MTU of 1500 and it's up to the administrator to set it
correctly.

Btw, PMTU events won't help with the metadata mode. And even in
"normal" mode, it's not clear what should be done - the tunnel
interface may be in a bridge, thus there may be other interfaces that
depend on the same MTU, up to inside VMs.

 Jiri
