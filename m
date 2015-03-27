From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH 2/2] ipvlan: always allow the broadcast MAC address
Date: Fri, 27 Mar 2015 18:46:29 +0100
Message-ID: <20150327184629.2f1e4f0e@griffin>
References: <1427409698.18540.11.camel@redhat.com>
	<1427409822.18540.13.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Mahesh Bandewar <maheshb@google.com>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33579 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751061AbbC0Rqd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Mar 2015 13:46:33 -0400
In-Reply-To: <1427409822.18540.13.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Mar 2015 17:43:42 -0500, Dan Williams wrote:
> ipvlan currently fails DHCP addressing for two reasons:
> 
> 1) DHCP offers are typically unicast back to the device's MAC
> address, and at the IP layer have a destination IP address
> matching the new lease address.  In ipvlan unicast packets
> are checked against existing addresses assigned to the ipvlan
> interface, so clearly this fails hard because the ipvlan
> interface has no IP addresses yet.  Workaround: request
> that the server broadcast replies (-B for dhclient), which
> don't get checked against the IP address list.
> 
> 2) Even when that's done, mac_filters only allows the
> broadcast MAC address when the interface has >= 1 IPv4
> addresses, so double-fail, and the incoming DHCP offer
> gets dropped on the floor again.
> 
> Instead of doing ugly stuff like watching for outgoing DHCP
> requests and adding the broadcast MAC to mac_filters for
> a period of time, just always allow the broadcast MAC.  This
> lets the ipvlan interface be configured with DHCP in
> Layer2 mode as long as as broadcast replies are used.
> 
> Signed-off-by: Dan Williams <dcbw@redhat.com>

I don't see any better option, either.

Reviewed-by: Jiri Benc <jbenc@redhat.com>

-- 
Jiri Benc
