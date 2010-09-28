From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v11 17/17]add two new ioctls for mp device.
Date: Tue, 28 Sep 2010 15:09:28 +0200
Message-ID: <20100928130928.GE14385@redhat.com>
References: <1285388855-27410-1-git-send-email-xiaohui.xin@intel.com>
 <b74412a16bc32fe2550461f25156e5b2563c5a2c.1285385607.git.xiaohui.xin@intel.com>
 <1285623375.2263.552.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xiaohui.xin@intel.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, davem@davemloft.net,
	herbert@gondor.hengli.com.au, jdike@linux.intel.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29173 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754563Ab0I1NPv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Sep 2010 09:15:51 -0400
Content-Disposition: inline
In-Reply-To: <1285623375.2263.552.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 27, 2010 at 10:36:15PM +0100, Ben Hutchings wrote:
> On Sat, 2010-09-25 at 12:27 +0800, xiaohui.xin@intel.com wrote:
> > From: Xin Xiaohui <xiaohui.xin@intel.com>
> > 
> > The patch add two ioctls for mp device.
> > One is for userspace to query how much memory locked to make mp device
> > run smoothly. Another one is for userspace to set how much meory locked
> > it really wants.
> [...]
> > diff --git a/include/linux/mpassthru.h b/include/linux/mpassthru.h
> > index ba8f320..083e9f7 100644
> > --- a/include/linux/mpassthru.h
> > +++ b/include/linux/mpassthru.h
> > @@ -7,6 +7,8 @@
> >  /* ioctl defines */
> >  #define MPASSTHRU_BINDDEV      _IOW('M', 213, int)
> >  #define MPASSTHRU_UNBINDDEV    _IO('M', 214)
> > +#define MPASSTHRU_SET_MEM_LOCKED	_IOW('M', 215, unsigned long)
> > +#define MPASSTHRU_GET_MEM_LOCKED_NEED	_IOR('M', 216, unsigned long)
> [...]
> 
> These will need compat handling.  You can avoid that by defining them to
> use a parameter type of u32 or u64.
> 
> Ben.

No need to introduce compat mess unless we have to.  I guess int is
sufficient: locking >= 2G just for guest networking is insane.

-- 
MST
