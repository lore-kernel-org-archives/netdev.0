From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [RFC] Validate ethtool autoneg before relaying
Date: Wed, 26 Nov 2008 15:44:06 -0800
Message-ID: <20081126234406.GA8970@xw6200.broadcom.net>
References: <20081126221741.GA8800@xw6200.broadcom.net>
 <1227742092.13189.19.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1305 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751336AbYKZXoU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Nov 2008 18:44:20 -0500
Received: from mail-irva-8.broadcom.com (mail-irva-8 [10.11.18.52]) by
 mail-irva-10.broadcom.com (Postfix) with ESMTP id 46E2E2B0 for
 <netdev@vger.kernel.org>; Wed, 26 Nov 2008 15:44:07 -0800 (PST)
Received: from NT-IRVA-0752.brcm.ad.broadcom.com (nt-irva-0752
 [10.8.194.67]) by mail-irva-13.broadcom.com (Postfix) with ESMTP id
 C78C474CFE for <netdev@vger.kernel.org>; Wed, 26 Nov 2008 15:44:06
 -0800 (PST)
In-Reply-To: <1227742092.13189.19.camel@HP1>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 26, 2008 at 03:28:12PM -0800, Michael Chan wrote:
> 
> On Wed, 2008-11-26 at 14:17 -0800, Matt Carlson wrote:
> > diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> > index 14ada53..6362f56 100644
> > --- a/net/core/ethtool.c
> > +++ b/net/core/ethtool.c
> > @@ -164,6 +164,9 @@ static int ethtool_set_settings(struct net_device *dev, void __user *useraddr)
> >         if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
> >                 return -EFAULT;
> >  
> > +       if (cmd.autoneg != AUTONEG_ENABLE && cmd.autoneg != AUTONEG_DISABLE)
> > +               return -EFAULT;
> > +
> 
> Matt, you should return -EINVAL here instead.

Yes.  You are right.  I'll fix this in a revised patch if everyone
decides this is an effort worth pursuing.

> >         return dev->ethtool_ops->set_settings(dev, &cmd);
> >  }
> >  
> 


