From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next] tun: return NET_XMIT_DROP for dropped packets
Date: Tue, 18 Nov 2014 11:53:28 -0800
Message-ID: <CAHA+R7O=vCtLwUPnkVpymxc9kp+a8ChS2MHAJahfJUNUdLX89A@mail.gmail.com>
References: <1416288041-30921-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416288041-30921-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 17, 2014 at 9:20 PM, Jason Wang <jasowang@redhat.com> wrote:
> After commit 5d097109257c03a71845729f8db6b5770c4bbedc
> ("tun: only queue packets on device"), NETDEV_TX_OK was returned for
> dropped packets. This will confuse pktgen since dropped packets were
> counted as sent ones.
>
> Fixing this by returning NET_XMIT_DROP to let pktgen count it as error
> packet.

pktgen is suspicious, it sends out packets directly without going through
qdisc, so it should not care about NET_XMIT_* qdisc error code?

Looks like NETDEV_TX_OK doesn't have to mean TX is successful,
the comment says driver takes care of the packet, can be either dropped
or sent out. We might need a new code to distinguish success or failure.
