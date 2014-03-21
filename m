From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [PATCH net] net: vxlan: fix crash when interface is created with
 no group
Date: Fri, 21 Mar 2014 17:31:55 +0200
Message-ID: <CAF1J0HPTV+XHORSLy3H-6-tBx91F0+L7UhnZd7YsGZCSEQad2Q@mail.gmail.com>
References: <1395055050-20874-1-git-send-email-mike.rapoport@ravellosystems.com>
	<20140320.160229.857536522237793124.davem@davemloft.net>
	<OFA209BE80.4610C3E5-ON87257CA1.00723468-87257CA1.0072346C@us.ibm.com>
	<CAF1J0HPE9L1Z4xst9ap_Z8nQ9k-N-UAbW7yre0S-wvQF5+NznA@mail.gmail.com>
	<OFD0C40ED9.015A05DD-ON87257CA2.003E72F3-87257CA2.003E7300@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f52.google.com ([209.85.219.52]:61623 "EHLO
	mail-oa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751488AbaCUPb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 11:31:56 -0400
Received: by mail-oa0-f52.google.com with SMTP id l6so2702171oag.11
        for <netdev@vger.kernel.org>; Fri, 21 Mar 2014 08:31:56 -0700 (PDT)
In-Reply-To: <OFD0C40ED9.015A05DD-ON87257CA2.003E72F3-87257CA2.003E7300@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 21, 2014 at 1:22 PM, David Stevens <dlstevens@us.ibm.com> wrote:
>
> -----Mike Rapoport <mike.rapoport@ravellosystems.com> wrote: -----
>
> Mike, ip_hdr() here is the outer packet, so it's got to be a UDP packet--
> we just don't know if it's UDP/IP or UDP/IPv6 when it is bound to INADDR_ANY,
> since both can be delivered. It could use version in this case, because
> both possible protocols have version in the same place, but I think it's
> more correct to use the MAC layer protocol rather than relying on the
> fact that IPv4 and IPv6 have "version" in the same spot. "It could be ARP"
> would be the argument for NOT using the version in places where it really
> could be ARP, even though that isn't the case here.
>
> vxlan_rcv() is only called for VXLAN encapsulated packets sent to the bound
> UDP port.
>
> So, if "vs->family" holds the one we want to support, we can't just blindly
> assume the received packet is IPv4, for example, and start accessing
> IPv4 fields, because it could be an IPv6 packet. We have to check the
> packet type too. And if it's not the one we bound to, drop it.
>
> That's what the code snippet I outlined is trying to do.
>

David,

I've tried your snippet with IPv4 and I've got all ARP replies
dropped. And if I enable IPv6 I still get crushes in ipv6_rcv.
It seems to me that at the time vxlan_rcv gets outer IP header, the
SKB contains mixed information of outer and inner packets.
I'll continue to look into it.


                                          +-DLS
>
>
>



-- 
Sincerely yours,
Mike.
