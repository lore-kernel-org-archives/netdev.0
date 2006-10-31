From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] wireless-2.6 zd1211rw check against regulatory domain rather than hardcoded value of 11
Date: Wed, 1 Nov 2006 00:48:02 +0100
Message-ID: <200611010048.03126.mb@bu3sch.de>
References: <f46018bb0610231121s4fb48f88l28a6e7d4f31d40bb@mail.gmail.com> <1162197749.2854.5.camel@ux156> <454683D1.4030200@deine-taler.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Daniel Drake <dsd@gentoo.org>,
	Holden Karau <holden@pigscanfly.ca>,
	zd1211-devs@lists.sourceforge.net, linville@tuxdriver.com,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
	holdenk@xandros.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:27576
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1946150AbWJaXtL
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Oct 2006 18:49:11 -0500
To: Uli Kunitz <kune@deine-taler.de>
In-Reply-To: <454683D1.4030200@deine-taler.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 30 October 2006 23:59, Uli Kunitz wrote:
> Johannes Berg wrote:
> >> I'm not so sure about this. This patching might be US-specific and we 
> >> cannot simply apply the setting for top channel of another domain 
> >> instead of channel 11. One option would be to set the value only under 
> >> the US regulatory domain.
> > 
> > ??
> > What the patch does is replace the top channel which is hardcoded to 11
> > by the top channel given by the current regulatory domain. How can that
> > be wrong? Except that you may want to init the regulatory domain from
> > the EEPROM but I'm not sure how the ieee80211 code works wrt. that.
> > 
> > johannes
> 
> The problem is not so much that I don't trust the geo code, but whether
> setting the register to that band-edge value for a higher channel is
> the right thing to do. It looks like that this is a hack for FFC
> compliance. Therefore I suggest to patch CR128 only
> for the US regulatory domain.
> 
> Here is the code from the GPL vendor driver (zdhw.c):
> 
>     if (pObj->HWFeature & BIT_21)  //6321 for FCC regulation, enabled HWFeature 6M band edge bit (for AL2230, AL2230S)
>      {
>          if (ChannelNo == 1 || ChannelNo == 11)  //MARK_003, band edge, these may depend on PCB layout
>          {
>              pObj->SetReg(reg, ZD_CR128, 0x12);
>              pObj->SetReg(reg, ZD_CR129, 0x12);
>              pObj->SetReg(reg, ZD_CR130, 0x10);
>              pObj->SetReg(reg, ZD_CR47, 0x1E);
>          }
>          else //(ChannelNo 2 ~ 10, 12 ~ 14)
>          {
>              pObj->SetReg(reg, ZD_CR128, 0x14);
>              pObj->SetReg(reg, ZD_CR129, 0x12);
>              pObj->SetReg(reg, ZD_CR130, 0x10);
>              pObj->SetReg(reg, ZD_CR47, 0x1E);
>          }
>      }
> 
> The patch from Holden would set ZD_CR128 to 0x12 for the highest channel,
> which would not reflect the logic of the vendor driver.

I think the real question is: What does this "band edge" bit actually do?
Did you notice any difference when setting it? Does TX power in/decrease?
Did you see differences in the physical range (max distance from the AP
for which you're still able to connect).
I don't know what channel 1 and 11 have in common. Why don't we set the
bit for channel 14? Isn't that an "edge", too?

-- 
Greetings Michael.
