From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] reduce netfilte sk_buff enlargement
Date: Thu, 21 Jul 2005 15:29:41 -0700 (PDT)
Message-ID: <20050721.152941.56567834.davem@davemloft.net>
References: <1121970035.5904.6.camel@notepaq>
	<20050721.131250.55509013.davem@davemloft.net>
	<1121982131.5886.2.camel@notepaq>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: laforge@netfilter.org, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org, wensong@linux-vs.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: marcel@holtmann.org
In-Reply-To: <1121982131.5886.2.camel@notepaq>
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

From: Marcel Holtmann <marcel@holtmann.org>
Date: Thu, 21 Jul 2005 23:42:11 +0200

> unfortunatly it is not that straight forward as I thought. The attached
> patch which modifies the Bluetooth core and the hci_usb driver is not
> working on my machine.

This probably has nothing to do with why the patch doesn't
work for you, but the transformation of "incoming" to a "u8"
from an "int" is not fully correct, because hci_sock.c
does this:

	put_cmsg(msg, SOL_HCI, HCI_CMSG_DIR, sizeof(int), &bt_cb(skb)->incoming);

I haven't found any other problems though...

Maybe the bluetooth code was somehow depending upon the initial
value of skb->pkt_type or something like that?
