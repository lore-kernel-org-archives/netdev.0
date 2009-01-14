From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: [PATCH 2/4] virtio_net: Add a virtqueue for outbound control
 commands
Date: Wed, 14 Jan 2009 16:37:06 +0000
Message-ID: <1231951026.4944.304.camel@localhost.localdomain>
References: <1231881797.9095.187.camel@bling>
	 <1231928110.4944.290.camel@localhost.localdomain>
	 <1231948868.7109.288.camel@lappy>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, kvm <kvm@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:36003 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759338AbZANQhQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:37:16 -0500
In-Reply-To: <1231948868.7109.288.camel@lappy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-01-14 at 09:01 -0700, Alex Williamson wrote:
> On Wed, 2009-01-14 at 10:15 +0000, Mark McLoughlin wrote:
> > On Tue, 2009-01-13 at 14:23 -0700, Alex Williamson wrote:

> > > +static int virtnet_send_command(struct virtnet_info *vi, u8 class, u8 cmd,
> > > +				void *data, unsigned int len)
> > > +{
> > > +	struct scatterlist sg[3];
> > > +	struct {
> > > +		u8 class;
> > > +		u8 cmd;
> > > +	} ctrl_cmd;
> > 
> > I'd like to see this defined in virtio_net_hdr.
> 
> As part of struct virtio_net_hdr?  I'm not sure what that'd buy us and
> would likely break compatibility.  Or do you simply mean defined in
> virtio-net.h?

Yep, sorry, I meant virtio-net.h

> > > +	u8 ctrl_status;
> > > +	unsigned int tmp;
> > > +	int i = 0;
> > > +
> > > +	if (!vi->cvq)
> > > +		return -EFAULT;
> > 
> > BUG_ON() probably makes more sense here.
> 
> This is to allow a newer virtio_net guest driver to run on an old qemu.
> That's why I don't generate a fatal error if we don't find the control
> queue.  In that case the backend will be running in promiscuous mode and
> I think all of these commands can safely fail.  Thanks for the comments.

Yep, but what I mean is that virtio_net_send_command() should never be
called if the host doesn't have send queue support - i.e. force the
calling code to think about what should be done on older hosts.

Cheers,
Mark.

