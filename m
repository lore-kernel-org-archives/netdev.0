From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: Network performance with small packets
Date: Thu, 03 Feb 2011 07:58:00 -0800
Message-ID: <1296748680.25430.169.camel@localhost.localdomain>
References: <20110202154706.GA12738@redhat.com>
	 <1296666635.25430.35.camel@localhost.localdomain>
	 <20110202173213.GA13907@redhat.com>
	 <1296670311.25430.49.camel@localhost.localdomain>
	 <20110202182720.GB14257@redhat.com>
	 <1296674975.25430.59.camel@localhost.localdomain>
	 <20110202201731.GB15150@redhat.com>
	 <1296680585.25430.98.camel@localhost.localdomain>
	 <20110202212047.GD15150@redhat.com>
	 <1296709556.25430.140.camel@localhost.localdomain>
	 <20110203061326.GC22230@redhat.com>
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
In-Reply-To: <20110203061326.GC22230@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-02-03 at 08:13 +0200, Michael S. Tsirkin wrote:
> > Initial TCP_STREAM performance results I got for guest to local
> host 
> > 4.2Gb/s for 1K message size, (vs. 2.5Gb/s)
> > 6.2Gb/s for 2K message size, and (vs. 3.8Gb/s)
> > 9.8Gb/s for 4K message size. (vs.5.xGb/s)
> 
> What is the average packet size, # bytes per ack, and the # of
> interrupts
> per packet? It could be that just slowing down trahsmission
> makes GSO work better. 

There is no TX interrupts with dropping packet.

GSO/TSO is the key for small message performance, w/o GSO/TSO, the
performance is limited to about 2Gb/s no matter how big the message size
it is. I think any work we try here will increase large packet size
rate. BTW for dropping packet, TCP increased fast retrans, not slow
start. 

I will collect tcpdump, netstart before and after data to compare packet
size/rate w/o w/i the patch.

Thanks
Shirley

