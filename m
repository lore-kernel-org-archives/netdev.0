From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] fix memory leak in virtio_net
Date: Wed, 12 Aug 2009 22:11:53 +0930
Message-ID: <200908122211.53890.rusty@rustcorp.com.au>
References: <1249934708.7400.10.camel@localhost.localdomain> <4A815B9A.3060205@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Shirley Ma <mashirle@us.ibm.com>, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4A815B9A.3060205@redhat.com>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 11 Aug 2009 09:22:58 pm Avi Kivity wrote:
> (copying Rusty, the virtio maintainer)
> 
> On 08/10/2009 11:05 PM, Shirley Ma wrote:
> > Whild reading virtio code, I found some memory leak in removing
> > virtio_net.
> >
> > In virtnet_remove, only skb has been freed not the pages in skb
> > frags. Here is the patch to fix this, please review it.

Nope, kfree_skb() frees the frags.

It needs to, otherwise we leak on every received packet!

Cheers,
Rusty.
