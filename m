From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH 1/1] vhost: TX used buffer guest signal accumulation
Date: Fri, 29 Oct 2010 10:03:47 +0200
Message-ID: <20101029080347.GA22688@redhat.com>
References: <1288216693.17571.38.camel@localhost.localdomain>
 <1288240804.14342.1.camel@localhost.localdomain>
 <20101028052021.GD5599@redhat.com>
 <1288294355.11251.20.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1288294355.11251.20.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 28, 2010 at 12:32:35PM -0700, Shirley Ma wrote:
> On Thu, 2010-10-28 at 07:20 +0200, Michael S. Tsirkin wrote:
> > My concern is this can delay signalling for unlimited time.
> > Could you pls test this with guests that do not have
> > 2b5bbe3b8bee8b38bdc27dd9c0270829b6eb7eeb
> > b0c39dbdc204006ef3558a66716ff09797619778
> > that is 2.6.31 and older? 
> 
> The patch only induces delay signaling unlimited time when there is no
> TX packet to transmit. I thought TX signaling only noticing guest to
> release the used buffers, anything else beside this?

Right, that's it I think. For newer kernels we orphan the skb
on xmit so we don't care that much about completing them.
This does rely on an undocumented assumption about guest
behaviour though.

> I tested rhel5u5 guest (2.6.18 kernel), it works fine. I checked the two
> commits log, I don't think this patch could cause any issue w/o these
> two patches.
> 
> Also I found a big TX regression for old guest and new guest. For old
> guest, I am able to get almost 11Gb/s for 2K message size, but for the
> new guest kernel, I can only get 3.5 Gb/s with the patch and same host.
> I will dig it why.
> 
> thanks
> Shirley
