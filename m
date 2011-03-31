From: Herton Ronaldo Krzesinski <herton.krzesinski@canonical.com>
Subject: Re: [RFC PATCH] rtl8187: Fix led support for rfkill
Date: Thu, 31 Mar 2011 14:19:03 -0300
Message-ID: <20110331171902.GA4010@herton-IdeaPad-Y430>
References: <1301174394-12642-1-git-send-email-wuzhangjin@gmail.com>
 <4D8E5BA3.1090909@users.sourceforge.net>
 <AANLkTind3Va9J_tvZBDAPfbuyQtgxoAE+ZzG6VpU1b1q@mail.gmail.com>
 <4D8E8B1E.3030709@users.sourceforge.net>
 <4D8FBE88.3050907@lwfinger.net>
 <20110328154046.GB2333@herton-IdeaPad-Y430>
 <AANLkTinwG5BR5=S14XYcwZ39c3k0xc9+2VsQFS+JHB0f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Hin-Tak Leung <htl10@users.sourceforge.net>,
	Herton Ronaldo Krzesinski <herton@canonical.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Roman Mamedov <rm@romanrm.ru>
To: wu zhangjin <wuzhangjin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from adelie.canonical.com ([91.189.90.139]:47675 "EHLO
	adelie.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758723Ab1CaRTO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2011 13:19:14 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTinwG5BR5=S14XYcwZ39c3k0xc9+2VsQFS+JHB0f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 01, 2011 at 12:22:51AM +0800, wu zhangjin wrote:
> On Mon, Mar 28, 2011 at 11:40 PM, Herton Ronaldo Krzesinski
> <herton.krzesinski@canonical.com> wrote:
> [...]
> >>
> >> My rtl8187 devices are both external USB sticks, thus they have no
> >> interaction with a radio-kill switch. I will test your patch to make
> >> sure it does no harm to my system.
> >>
> >> I think the commit message should be revised. A simple statement
> >> like "the LED does not turn off when the rfkill switch is off"
> >> should be sufficient.
> >
> > The patch should work, but I wonder if we should be fiddling with priv->vif
> > for this, perhaps we should not assume vif to be valid after
> > rtl8187_remove_interface (I don't see problems with current
> > rtl8187/mac80211 code on a quick look, but...)
> >
> 
> Yes, but seems only two places have touched the vif pointer.
> 
> $ grep "vif =" -ur drivers/net/wireless/rtl818x/rtl8187/
> drivers/net/wireless/rtl818x/rtl8187/dev.c:	priv->vif = NULL;
> drivers/net/wireless/rtl818x/rtl8187/dev.c:	priv->vif = vif;
> 
> > I cleaner solution may be to use a priv->mode like p54.
> 
> Yep, then, we may need to add a 'mode' member to rtl8187_priv and
> update it properly like p54.
> 
> So, What do you prefer? I will prepare a new patch asap.

In the led code we dereference priv->vif, checking for priv->vif->type.
vif is a pointer from mac80211, and after rtl8187_remove_interface is
called by it, at least from my POV can do anything it wants with vif,
like freeing the sdata vif points to. From what I checked, it doesn't
free currently and your patch don't have issues, but may be it's better
to be safe and add a new "future proof" mode field.

And as your bug shows, the led code access priv->vif after
rtl8187_remove_interface, so we hit the case where vif could be
considered invalid.

So because of this and being cleaner I would go adding 'mode'.

> 
> Best Regards,
> Wu Zhangjin
> 
> >
> >>
> >> Larry
> >>
> >
> > --
> > []'s
> > Herton
> >
> 

-- 
[]'s
Herton
