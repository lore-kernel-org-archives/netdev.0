From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: Network performance with small packets
Date: Thu, 03 Feb 2011 09:18:36 -0800
Message-ID: <1296753516.25430.205.camel@localhost.localdomain>
References: <20110202173213.GA13907@redhat.com>
	 <1296670311.25430.49.camel@localhost.localdomain>
	 <20110202182720.GB14257@redhat.com>
	 <1296674975.25430.59.camel@localhost.localdomain>
	 <20110202201731.GB15150@redhat.com>
	 <1296680585.25430.98.camel@localhost.localdomain>
	 <20110202212047.GD15150@redhat.com>
	 <1296709556.25430.140.camel@localhost.localdomain>
	 <20110203061326.GC22230@redhat.com>
	 <1296748680.25430.169.camel@localhost.localdomain>
	 <20110203162042.GA10028@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	mashirle@linux.vnet.ibm.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, Sridhar Samudrala <sri@us.ibm.com>,
	Steve Dobbelstein <steved@us.ibm.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110203162042.GA10028@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-02-03 at 18:20 +0200, Michael S. Tsirkin wrote:
> Just a thought: does it help to make tx queue len of the
> virtio device smaller? 

Yes, that what I did before, reducing txqueuelen will cause qdisc dropp
the packet early, But it's hard to control by using tx queuelen for
performance gain. I tried on different systems, it required different
values.

Also, I tried another patch, instead of dropping packets, I used to
timer (2 jiffies) to enable/disable queue on guest without interrupts
notification, it gets better performance than original but worse
performance than dropping packets because of netif stop/wake up too
often.

vhost is definitely needed to improve for handling small message sizes.
It's unable to handle small message packets rate for queue size 256,
even with ring size 1024. QEMU seems not allowing to increase the TX
ring size to 2K (start qemu_kvm failure with no errors), I am not able
to test it out.

Thanks
Shirley

