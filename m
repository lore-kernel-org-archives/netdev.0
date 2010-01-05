From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] net: packet: option to only pass skb protocol
Date: Wed, 6 Jan 2010 00:27:48 +0200
Message-ID: <20100105222748.GG30921@redhat.com>
References: <20100105185732.GA30346@redhat.com> <4B43AEF6.6050701@nortel.com> <20100105.134218.258781374.davem@davemloft.net> <4B43B989.4010004@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	nhorman@tuxdriver.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35655 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752631Ab0AEWay (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jan 2010 17:30:54 -0500
Content-Disposition: inline
In-Reply-To: <4B43B989.4010004@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 05, 2010 at 04:13:29PM -0600, Chris Friesen wrote:
> On 01/05/2010 03:42 PM, David Miller wrote:
> > From: "Chris Friesen" <cfriesen@nortel.com>
> > Date: Tue, 05 Jan 2010 15:28:22 -0600
> > 
> >> On 01/05/2010 12:57 PM, Michael S. Tsirkin wrote:
> >>> When sending packets with a packet socket it is often necessary to set
> >>> protocol in msg_name: otherwise the protocol field in the skb will not
> >>> be set correctly.
> >>
> >> What about automatically detecting the protocol from the data being sent
> >> to avoid the necessity of specifying it in the first place?
> > 
> > This limits packet socket usage to only protocols the kernel is aware
> > of, defeating part of the usefulness of the packet socket facility.
> 
> I don't follow.
> 
> If SOCK_RAW packets are being sent, the protocol number is embedded in
> the packet data and the kernel should be able to extract it regardless
> of whether the kernel actually supports it or not.  I see that Michael
> just posted a patch for this.
> 
> If SOCK_DGRAM packets are being sent, then I agree that the app needs to
> pass it down at send time or at bind() time to support protocols of
> which the kernel is not aware.
> 
> While looking at the code I noticed that while the protocol number is
> validated at socket creation time it does not appear to be validated for
> calls to bind() for packet sockets.  Is this intentional?
> 
> As a further question, does it actually make sense to check the protocol
> number at packet socket creation?  It seems like we should be able to
> allow a packet socket to specify arbitrary protocol numbers since the
> kernel doesn't really need to do anything with them.
> 
> Chris

I wouldn't say kernel doesn't really need to do anything with them.

In fact I think currently protocol number affects whether other packet
sockets see the packet in question.  There may be other cases, e.g. if
the device in question is a bridge, the packet gets reinjected in host
stack, so using a silly value for protocol field might interfere with
GRO etc.


-- 
MST
