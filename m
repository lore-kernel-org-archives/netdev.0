From: Herton Ronaldo Krzesinski <herton.krzesinski@canonical.com>
Subject: Re: [RFC PATCH] rtl8187: Fix led support for rfkill
Date: Mon, 28 Mar 2011 12:40:47 -0300
Message-ID: <20110328154046.GB2333@herton-IdeaPad-Y430>
References: <1301174394-12642-1-git-send-email-wuzhangjin@gmail.com>
 <4D8E5BA3.1090909@users.sourceforge.net>
 <AANLkTind3Va9J_tvZBDAPfbuyQtgxoAE+ZzG6VpU1b1q@mail.gmail.com>
 <4D8E8B1E.3030709@users.sourceforge.net>
 <4D8FBE88.3050907@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hin-Tak Leung <htl10@users.sourceforge.net>,
	wu zhangjin <wuzhangjin@gmail.com>,
	Herton Ronaldo Krzesinski <herton@canonical.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Roman Mamedov <rm@romanrm.ru>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from adelie.canonical.com ([91.189.90.139]:48496 "EHLO
	adelie.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753589Ab1C1Pk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2011 11:40:56 -0400
Content-Disposition: inline
In-Reply-To: <4D8FBE88.3050907@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 27, 2011 at 05:47:36PM -0500, Larry Finger wrote:
> On 03/26/2011 07:55 PM, Hin-Tak Leung wrote:
> >wu zhangjin wrote:
> >>On Sun, Mar 27, 2011 at 5:33 AM, Hin-Tak Leung
> >><htl10@users.sourceforge.net> wrote:
> >>>Wu Zhangjin wrote:
> >>>>led can not be turned off normally when rfkill is blocked, the cause is
> >>>>the led_turn_off() function exit as not expected:
> >>>Hmm. While this sounds more sensible, is it needed? And what does the
> >>>windows driver do?
> >>>
> >>>I think there are two kind of LEDs - one that comes on and off with the
> >>>rfkill switch; Larry or Herton makes the 2nd one, if there is one, blink
> >>>while there is traffic (and stay steady on otherwise).
> >>
> >>I have used this driver on the YeeLoong netbook(only support Linux),
> >>there is only one LED for rtl8187, when there is traffic, it blinks
> >>perfectly, but If press the hotkey to turn off the rf, the network
> >>interface is down, but the LED is still light, then, the users may
> >>mistakenly think the hotkey or rfkill support doesn't work or simply
> >>think the interface is still on. So, that's why we may need to fix it.
> >
> >My laptop (a Toshiba one) has the other kind of LED - the LED only comes on and
> >off in relation to the rfkill switch, and does not blink with traffic. I think
> >Herton or Larry has some devices with both types.

I had one via based netbook with proper led, but don't have it anymore.

> >
> >Hmm, I seem to have the impression that there is code somewhere for switching a
> >singular LED's behavior of the driver between one or the other, by echo'ing into
> >sysfs or some other trickery? Or would that be a desired approach if that's not
> >done at the moment?
> 
> My rtl8187 devices are both external USB sticks, thus they have no
> interaction with a radio-kill switch. I will test your patch to make
> sure it does no harm to my system.
> 
> I think the commit message should be revised. A simple statement
> like "the LED does not turn off when the rfkill switch is off"
> should be sufficient.

The patch should work, but I wonder if we should be fiddling with priv->vif
for this, perhaps we should not assume vif to be valid after
rtl8187_remove_interface (I don't see problems with current
rtl8187/mac80211 code on a quick look, but...)

I cleaner solution may be to use a priv->mode like p54.

> 
> Larry
> 

-- 
[]'s
Herton
