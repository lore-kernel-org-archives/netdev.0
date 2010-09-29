From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [RFC PATCH 2/2] macvtap: TX zero copy between guest and host
 kernel
Date: Tue, 28 Sep 2010 20:24:29 -0700
Message-ID: <1285730669.31343.7.camel@localhost.localdomain>
References: <20100914152231.GA13105@redhat.com>
	 <1284480025.13351.49.camel@localhost.localdomain>
	 <20100914162952.GB13560@redhat.com>
	 <1284483745.13351.71.camel@localhost.localdomain>
	 <20100914182707.GB15549@redhat.com>
	 <1284490143.13351.82.camel@localhost.localdomain>
	 <20100914190156.GA16037@redhat.com>
	 <1284492983.13351.95.camel@localhost.localdomain>
	 <20100915051241.GA25340@redhat.com>
	 <1284531675.24603.259.camel@localhost.localdomain>
	 <20100915101000.GB28016@redhat.com>
	 <1284562354.2573.12.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, Avi Kivity <avi@redhat.com>,
	"Xin, Xiaohui" <xiaohui.xin@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1284562354.2573.12.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Michael,

On Wed, 2010-09-15 at 07:52 -0700, Shirley Ma wrote:
> > >  Don't you think once I address vhost_add_used_and_signal update
> > > issue, it is a simple and complete patch for macvtap TX zero copy?
> > > 
> > > Thanks
> > > Shirley
> > 
> > I like the fact that the patch is simple. Unfortunately
> > I suspect it'll stop being simple by the time it's complete :) 
> 
> I can make a try. :)

I compared several approaches for addressing the issue being raised here
on how/when to update vhost_add_used_and_signal. The simple approach I
have found is:

1. Adding completion field in struct virtqueue;
2. when it is a zero copy packet, put vhost thread wait for completion
to update vhost_add_used_and_signal;
3. passing vq from vhost to macvtap as skb destruct_arg;
4. when skb is freed for the last reference, signal vq completion

The test results show same performance as the original patch. How do you
think? If it sounds good to you. I will resubmit this reversion patch.
The patch still keeps as simple as it was before. :)

Thanks
Shirley
