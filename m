From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] reduce netfilte sk_buff enlargement
Date: Fri, 22 Jul 2005 01:49:51 +0200
Message-ID: <1121989791.5892.8.camel@notepaq>
References: <1121970035.5904.6.camel@notepaq>
	<20050721.131250.55509013.davem@davemloft.net>
	<1121982131.5886.2.camel@notepaq>
	<20050721.152941.56567834.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: laforge@netfilter.org, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org, wensong@linux-vs.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050721.152941.56567834.davem@davemloft.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Hi Dave,

> > unfortunatly it is not that straight forward as I thought. The attached
> > patch which modifies the Bluetooth core and the hci_usb driver is not
> > working on my machine.
> 
> This probably has nothing to do with why the patch doesn't
> work for you, but the transformation of "incoming" to a "u8"
> from an "int" is not fully correct, because hci_sock.c
> does this:
> 
> 	put_cmsg(msg, SOL_HCI, HCI_CMSG_DIR, sizeof(int), &bt_cb(skb)->incoming);
> 
> I haven't found any other problems though...

actually I overlooked it. Thanks for spotting it. I fixed it by copying
it into an int first. However this is only used when you really request
the direction bit and this happens only with hcidump from userspace as
far as I know.

> Maybe the bluetooth code was somehow depending upon the initial
> value of skb->pkt_type or something like that?

The pkt_type zero is not a valid one. We only use 1-4 and 0xff. So this
can't be the problem. I assume that the cb is not copied from the driver
into the core at some point.

Regards

Marcel
