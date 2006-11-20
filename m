From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: d80211: RFC: divide by zero when hw->maxssi not set
Date: Mon, 20 Nov 2006 13:45:07 +0100
Message-ID: <200611201345.08445.netdev@axxeo.de>
References: <20061117235109.GA11885@devicescape.com> <1163980523.2881.33.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: David Kimdon <david.kimdon@devicescape.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:20698 "EHLO mail.axxeo.de")
	by vger.kernel.org with ESMTP id S934145AbWKTMp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 07:45:29 -0500
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1163980523.2881.33.camel@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi there,

Dan Williams schrieb:
> On Fri, 2006-11-17 at 15:51 -0800, David Kimdon wrote:
> > commit 448bf25bc9e3d70a211fdf235426472089371c43 added
> > ieee80211_get_wireless_stats in net/d80211/ieee80211_ioctl.c.  At
> > present we get a divide by zero (oops) if the low level driver does
> > not set the new hw->maxssi field.  Perhaps:
> > 
> > - reject registration of devices which do not set maxssi

> #1 could be too draconian, but has the benefit of making driver writers
> put _something_ there.  Either way, it's pretty obvious to anyone that
> the driver is broken for quality reporting.  But at least #1 forces the
> issue to making quality somewhat work.

Looks like a perfect cancdidate for -EINVAL and WARN_ON() at registration.
BUG_ON() is also ok, until that stuff is widely deployed.

That's much better than dummy values, because it doesn't make
people think "Hmm, it works somehow, but I don't know why 
(and I don't care why)".


Regards

Ingo Oeser
