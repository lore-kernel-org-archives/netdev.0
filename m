From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH V3 2/8] Add a new zerocopy device flag
Date: Tue, 03 May 2011 13:11:21 -0700
Message-ID: <1304453481.20660.39.camel@localhost.localdomain>
References: <1303328216.19336.18.camel@localhost.localdomain>
	 <1303328648.19336.24.camel@localhost.localdomain>
	 <20110502104257.GA21625@redhat.com>
	 <1304362028.20660.15.camel@localhost.localdomain>
	 <20110502195302.GA25619@redhat.com>
	 <1304444570.20660.32.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304444570.20660.32.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-05-03 at 10:42 -0700, Shirley Ma wrote:
> Better to prevent this kind of skbs to be used in skb_clone, expand
> head
> for now.

I looked at the code, skb_clone shouldn't have any problem since ubuf
callback is only called after the lower device DMA has done. I can
modify the zerocopy len to 256 bytes so expand head should be OK as
well. So we only need to prevent recycle skb. I also checked the device
drivers, only a few device do RX buffers recycle. So there shouldn't be
any problem.

I will add more comments here to make sure when ZEROCOPY flag is set,
the ubuf callback should only be called when last reference to this skb
is gone.


Thanks
Shirley
