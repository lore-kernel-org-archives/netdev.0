From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH v2 1/4] Defer skb allocation -- add destroy buffers
 function for virtio
Date: Mon, 14 Dec 2009 12:08:05 -0800
Message-ID: <1260821285.8716.7.camel@localhost.localdomain>
References: <1258697359.7416.14.camel@localhost.localdomain>
	 <200911231123.18898.rusty@rustcorp.com.au>
	 <20091208122134.GA17286@redhat.com>
	 <1260534506.30371.6.camel@localhost.localdomain>
	 <1260534805.30371.10.camel@localhost.localdomain>
	 <20091213102632.GB6789@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Anthony Liguori <anthony@codemonkey.ws>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20091213102632.GB6789@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Michael,

I agree with the comments (will have two patches instead of 4 based on
Rusty's comments) except below one.

On Sun, 2009-12-13 at 12:26 +0200, Michael S. Tsirkin wrote:
> That said - do we have to use a callback?
> I think destroy_buf which returns data pointer,
> and which we call repeatedly until we get NULL
> or error, would be an a better, more flexible API.
> This is not critical though.

The reason to use this is because in virtio_net remove, it has
BUG_ON(vi->num != 0), which will be consistent with small skb packet. If
we use NULL, error then we lose the track for vi->num, since we don't
know how many buffers have been passed to ULPs or still unused.

Thanks
Shirley

