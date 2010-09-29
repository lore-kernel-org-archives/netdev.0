From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [RFC PATCH 2/2] macvtap: TX zero copy between guest and host
 kernel
Date: Wed, 29 Sep 2010 07:37:05 -0700
Message-ID: <1285771025.31343.11.camel@localhost.localdomain>
References: <1284483745.13351.71.camel@localhost.localdomain>
	 <20100914182707.GB15549@redhat.com>
	 <1284490143.13351.82.camel@localhost.localdomain>
	 <20100914190156.GA16037@redhat.com>
	 <1284492983.13351.95.camel@localhost.localdomain>
	 <20100915051241.GA25340@redhat.com>
	 <1284531675.24603.259.camel@localhost.localdomain>
	 <20100915101000.GB28016@redhat.com>
	 <1284562354.2573.12.camel@localhost.localdomain>
	 <1285730669.31343.7.camel@localhost.localdomain>
	 <20100929081645.GA21195@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, Avi Kivity <avi@redhat.com>,
	"Xin, Xiaohui" <xiaohui.xin@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100929081645.GA21195@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-09-29 at 10:16 +0200, Michael S. Tsirkin wrote:
> > I compared several approaches for addressing the issue being raised
> here
> > on how/when to update vhost_add_used_and_signal. The simple approach
> I
> > have found is:
> > 
> > 1. Adding completion field in struct virtqueue;
> > 2. when it is a zero copy packet, put vhost thread wait for
> completion
> > to update vhost_add_used_and_signal;
> > 3. passing vq from vhost to macvtap as skb destruct_arg;
> > 4. when skb is freed for the last reference, signal vq completion
> > The test results show same performance as the original patch. How do
> you
> > think? If it sounds good to you. I will resubmit this reversion
> patch.
> > The patch still keeps as simple as it was before. :)
> > 
> > Thanks
> > Shirley
> 
> If you look at dev_hard_start_xmit you will see a call
> to skb_orphan_try which often calls the skb destructor.
> So I suspect this is almost equivalent to your original patch,
> and has the same correctness issue. 

If I didn't address this, then vhost net will wait for ever with wait
for completion :))


Thanks
Shirley
