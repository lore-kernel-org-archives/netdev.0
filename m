From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [PATCH 1/2] Ethtool: Add EEE support
Date: Wed, 6 Jun 2012 18:21:16 +0100
Message-ID: <1339003276.2836.31.camel@bwh-desktop.uk.solarflarecom.com>
References: <1338878470-24784-1-git-send-email-yuvalmin@broadcom.com>
	 <1338878470-24784-2-git-send-email-yuvalmin@broadcom.com>
	 <1338997734.2836.17.camel@bwh-desktop.uk.solarflarecom.com>
	 <979A8436335E3744ADCD3A9F2A2B68A502687E@SJEXCHMB10.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>,
	"peppe.cavallaro@st.com" <peppe.cavallaro@st.com>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:22633 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757507Ab2FFRVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 13:21:23 -0400
In-Reply-To: <979A8436335E3744ADCD3A9F2A2B68A502687E@SJEXCHMB10.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-06 at 16:27 +0000, Yuval Mintz wrote:
> Hi Ben,
> 
> I stand corrected; I'll supply a new version shortly. 
> 
> I've got 2 questions  though:
> 
> > For now, use int for booleans.  At some point I would like to see a
> > thorough cleanup of ethtool to use bool where appropriate - but that's
> > independent of this
> 
> I've noticed that the 'do_generic_set' function assumes all fields are ints.

Yes, but that can and should be fixed.

> Is this a convention we should stick to (using  __u32 in the ethtool structs)?

Yes.  It is generally preferable to use explicitly fixed-size types in
kernel-userland ABI, even though I wouldn't expect the size of int to
change for many decades to come.

> I'm asking because I'm "wasting" fields in the ethtool_eee struct as I use
> __u32 for boolean fields, simply because what seems to be the conventional
> method won't work with smaller fields (corrupts the following fields).

It's slightly wasteful but not worth worrying about.

> The seconds question - is there a dependency between your acceptance of
> this patch series and Dave's acceptance of the kernel's ethtool modification?
> I'm asking because changes in the ethtool header there should be applied in
> this patch series as well (in ethtool-copy.h).

There is a dependency, yes.  However I generally update ethtool-copy.h
as a separate commit myself (as you can see in the git commit log for
it) so I won't demand that you refresh the version in your patch.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
