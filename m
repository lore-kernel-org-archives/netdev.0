From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] vhost-net: utilize PUBLISH_USED_IDX feature
Date: Thu, 20 May 2010 13:48:52 +0930
Message-ID: <201005201348.53702.rusty@rustcorp.com.au>
References: <20100518011931.GA21918@redhat.com> <4BF41A33.8090309@redhat.com> <20100519222718.GB4111@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Avi Kivity <avi@redhat.com>, davem@davemloft.net,
	Juan Quintela <quintela@redhat.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>, kvm@vger.kernel.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, alex.williamson@redhat.com,
	amit.shah@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:58224 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752306Ab0ETETB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 May 2010 00:19:01 -0400
In-Reply-To: <20100519222718.GB4111@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 May 2010 07:57:18 am Michael S. Tsirkin wrote:
> On Wed, May 19, 2010 at 08:04:51PM +0300, Avi Kivity wrote:
> > On 05/18/2010 04:19 AM, Michael S. Tsirkin wrote:
> >> With PUBLISH_USED_IDX, guest tells us which used entries
> >> it has consumed. This can be used to reduce the number
> >> of interrupts: after we write a used entry, if the guest has not yet
> >> consumed the previous entry, or if the guest has already consumed the
> >> new entry, we do not need to interrupt.
> >> This imporves bandwidth by 30% under some workflows.
> >>
> >> Signed-off-by: Michael S. Tsirkin<mst@redhat.com>
> >> ---
> >>
> >> Rusty, Dave, this patch depends on the patch
> >> "virtio: put last seen used index into ring itself"
> >> which is currently destined at Rusty's tree.
> >> Rusty, if you are taking that one for 2.6.35, please
> >> take this one as well.
> >> Dave, any objections?
> >>    
> >
> > I object: I think the index should have its own cacheline,
> 
> The issue here is that host/guest do not know each
> other's cache line size. I guess we could just put it
> at offset 128 or something like that ... Rusty?

I was assuming you'd put it at the end of the padding.

I think it's a silly optimization, but Avi obviously feels strongly about
it and I respect his opinion.

Please resubmit...
Thanks,
Rusty.
