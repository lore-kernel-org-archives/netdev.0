From: "Simon Barber" <simon@devicescape.com>
Subject: RE: [RFC] [PATCH 0/3] Add Regulatory Domain support to d80211
Date: Tue, 24 Oct 2006 13:03:45 -0700
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F018523A5@dhost002-46.dex002.intermedia.net>
References: <20061024140212.GB17543@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "Jiri Benc" <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Jean Tourrilhes" <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-46.dex002.intermedia.net ([64.78.21.140]:19376 "EHLO
	dhost002-46.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1161223AbWJXUDc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2006 16:03:32 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20061024140212.GB17543@devicescape.com>
To: "David Kimdon" <david.kimdon@devicescape.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Client MLME code in the kernel was only ever written to be used for
quick testing. It does not have good roaming performance, and was never
intended to be a complete client. The right place for the Client MLME is
in userspace, where it can be closely coupled with the supplicant, and
better scanning and roaming decisions can be made. If the Client MLME is
removed from the kernel, then a userspace part is always required in
order for 802.11 to be used at all. (It's already required in order to
use any of the recent security modes, or have automatic network
selection, or decent roaming). In this case the regulatory constraints
can be set in a privileged userspace deamon.

Simon

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of David Kimdon
Sent: Tuesday, October 24, 2006 7:02 AM
To: Luis R. Rodriguez
Cc: netdev@vger.kernel.org; Jiri Benc; John W. Linville; Jean Tourrilhes
Subject: Re: [RFC] [PATCH 0/3] Add Regulatory Domain support to d80211

Hi,

> The following patches extend 802.11 regulatory domain support of the
> d80211 wireless stack through two modules:
> 
> 1. ieee80211_regdomains
> 2. iso3166-1

I am glad to see this work, this is something that we need a solution
for.  I do wonder if we can push most of this out of the kernel and into
userspace.  We could hard code a single set of constraints in the kernel
which may be used world wide (802.11b channels 1-11, is that allowed
everywhere?).  Then we have a userspace tool which passes updated
regulatory information into the kernel based on the user's country
input.

-David
-
To unsubscribe from this list: send the line "unsubscribe netdev" in the
body of a message to majordomo@vger.kernel.org More majordomo info at
http://vger.kernel.org/majordomo-info.html
