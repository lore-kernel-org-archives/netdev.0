From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH for-2.6.35] virtio_net: fix oom handling on tx
Date: Tue, 15 Jun 2010 13:53:29 +0930
Message-ID: <201006151353.30529.rusty@rustcorp.com.au>
References: <20100610152041.GA3480@redhat.com> <20100610104653.1aed2ecc@nehalam> <20100610190343.GC4044@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	virtualization@lists.linux-foundation.org,
	Jiri Pirko <jpirko@redhat.com>, Shirley Ma <xma@us.ibm.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100610190343.GC4044@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 11 Jun 2010 04:33:43 am Michael S. Tsirkin wrote:
> On Thu, Jun 10, 2010 at 10:46:53AM -0700, Stephen Hemminger wrote:
> > It makes more sense to have the device increment tx_droppped, 
> > and return NETDEV_TX_OK. Skip the message (or make it a pr_debug()). 
> > Network devices do not guarantee packet delivery, and if out of
> > resources then holding more data in the
> > queue is going to hurt not help the situation.

Yes, actually oom should be a ratelimited message and TX_OK, the other
case is a "should never happen" logic bug which warrants an error and
I don't care what it returns (whatever's easiest).

Please fix both at once since you're touching it.

Thanks,
Rusty.
