From: Victor Kaplansky <victork@redhat.com>
Subject: Re: [PATCH v2 2/2] virtio-net: add default_mtu configuration field
Date: Wed, 19 Aug 2015 14:31:59 +0300
Message-ID: <20150819140836-mutt-send-email-victork@redhat.com>
References: <1439732494-29765-1-git-send-email-victork@redhat.com>
 <1439732494-29765-3-git-send-email-victork@redhat.com>
 <55D14FE3.8040307@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: virtio-dev@lists.oasis-open.org, mst@redhat.com,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58867 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752483AbbHSLcC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 07:32:02 -0400
Content-Disposition: inline
In-Reply-To: <55D14FE3.8040307@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 17, 2015 at 11:07:15AM +0800, Jason Wang wrote:
> 
> 
> On 08/16/2015 09:42 PM, Victor Kaplansky wrote:
> > @@ -3128,6 +3134,7 @@ struct virtio_net_config {
> >          u8 mac[6];
> >          le16 status;
> >          le16 max_virtqueue_pairs;
> > +        le16 default_mtu;
> 
> Looks like "mtu" is ok, consider we use "mac" instead of "default_mac".

Good point. I'll change the name in the next version of the patch.

> 
> >  };
> >  \end{lstlisting}
> >  
> > @@ -3158,6 +3165,15 @@ by the driver after negotiation.
> >      \field{max_virtqueue_pairs} is valid only if VIRTIO_NET_F_MQ is
> >      set and can be read by the driver.
> >  
> > +\item [\field{default_mtu}] is a hint to the driver set by the
> > +    device. It is valid during feature negotiation only if
> > +    VIRTIO_NET_F_DEFAULT_MTU is offered and holds the initial value
> > +    of MTU to be used by the driver. If VIRTIO_NET_F_DEFAULT_MTU is
> > +    negotiated, the driver uses the \field{default_mtu} as an initial
> > +    value, and also reports MTU changes to the device by writes to
> > +    \field{default_mtu}.  Such reporting can be used for debugging,
> > +    or it can be used for tunning MTU along the network.
> > +
> 
> I vaguely remember that config is read only in some arch or transport
> and that's why we introduce another vq cmd to confirm the announcement.
> Probably we should do same for this?

If so, we need to add one more feature bit to confirm the ability
of the driver to report MTU, or we can weaken the requirement in
conformance statement and write "the driver may report the MTU".
What do you say?

-- Victor
