From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: [PATCH] net: packet: option to only pass skb protocol
Date: Tue, 05 Jan 2010 16:13:29 -0600
Message-ID: <4B43B989.4010004@nortel.com>
References: <20100105185732.GA30346@redhat.com>	<4B43AEF6.6050701@nortel.com> <20100105.134218.258781374.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, eric.dumazet@gmail.com, nhorman@tuxdriver.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754990Ab0AEWRm@vger.kernel.org>
In-Reply-To: <20100105.134218.258781374.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/05/2010 03:42 PM, David Miller wrote:
> From: "Chris Friesen" <cfriesen@nortel.com>
> Date: Tue, 05 Jan 2010 15:28:22 -0600
> 
>> On 01/05/2010 12:57 PM, Michael S. Tsirkin wrote:
>>> When sending packets with a packet socket it is often necessary to set
>>> protocol in msg_name: otherwise the protocol field in the skb will not
>>> be set correctly.
>>
>> What about automatically detecting the protocol from the data being sent
>> to avoid the necessity of specifying it in the first place?
> 
> This limits packet socket usage to only protocols the kernel is aware
> of, defeating part of the usefulness of the packet socket facility.

I don't follow.

If SOCK_RAW packets are being sent, the protocol number is embedded in
the packet data and the kernel should be able to extract it regardless
of whether the kernel actually supports it or not.  I see that Michael
just posted a patch for this.

If SOCK_DGRAM packets are being sent, then I agree that the app needs to
pass it down at send time or at bind() time to support protocols of
which the kernel is not aware.

While looking at the code I noticed that while the protocol number is
validated at socket creation time it does not appear to be validated for
calls to bind() for packet sockets.  Is this intentional?

As a further question, does it actually make sense to check the protocol
number at packet socket creation?  It seems like we should be able to
allow a packet socket to specify arbitrary protocol numbers since the
kernel doesn't really need to do anything with them.

Chris
