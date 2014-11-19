From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tun: return NET_XMIT_DROP for dropped packets
Date: Wed, 19 Nov 2014 14:46:04 -0500 (EST)
Message-ID: <20141119.144604.269852847904624488.davem@davemloft.net>
References: <1416288041-30921-1-git-send-email-jasowang@redhat.com>
	<CAHA+R7O=vCtLwUPnkVpymxc9kp+a8ChS2MHAJahfJUNUdLX89A@mail.gmail.com>
	<546C0B58.5030402@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cwang@twopensource.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <546C0B58.5030402@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Wed, 19 Nov 2014 11:15:36 +0800

> On 11/19/2014 03:53 AM, Cong Wang wrote:
>> On Mon, Nov 17, 2014 at 9:20 PM, Jason Wang <jasowang@redhat.com> wrote:
>>> > After commit 5d097109257c03a71845729f8db6b5770c4bbedc
>>> > ("tun: only queue packets on device"), NETDEV_TX_OK was returned for
>>> > dropped packets. This will confuse pktgen since dropped packets were
>>> > counted as sent ones.
>>> >
>>> > Fixing this by returning NET_XMIT_DROP to let pktgen count it as error
>>> > packet.
>> pktgen is suspicious, it sends out packets directly without going through
>> qdisc, so it should not care about NET_XMIT_* qdisc error code?
> 
> Well, NET_XMIT_DROP has been used by some devices. I don't see any side
> effect of using this especially consider that pktgen can recognize them.
>> Looks like NETDEV_TX_OK doesn't have to mean TX is successful,
>> the comment says driver takes care of the packet, can be either dropped
>> or sent out. We might need a new code to distinguish success or failure.
> 
> Most drivers only drop bad packets when they return NETDEV_TX_OK and
> they will stop the txq before tx ring is full. This is not the case of
> tun, it never stop txq and keep accepting packets and dropping them when
> socket receive queue is full.

Agreed.

Often the issue with TX return values is lack of clear documentation
and use cases.

I've applied this patch, thanks Jason.
