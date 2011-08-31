From: "Vlad Zolotarov" <vladz@broadcom.com>
Subject: Re: [PATCH 7/7] bnx2x: expose HW RX VLAN stripping toggle
Date: Wed, 31 Aug 2011 15:01:39 +0300
Message-ID: <201108311501.39936.vladz@broadcom.com>
References: <1314714646-3642-1-git-send-email-mschmidt@redhat.com>
 <CAHXqBFLgTHvxL34eR1qX7nEmntyOBXYrg-7LQvW=d8dnDpbhWg@mail.gmail.com>
 <4E5D3A43.1060202@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: =?utf-8?q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Michal Schmidt" <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1105 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752835Ab1HaMC0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 08:02:26 -0400
In-Reply-To: <4E5D3A43.1060202@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 30 August 2011 22:30:11 Michal Schmidt wrote:

> > and then also in fp->flags.  Are the
> > fp->flags strictly mirroring hardware state (as in: there is no way
> > the states can differ in any point in time where the flags are
> > tested)?
> 
> Yes. This is the purpose of the second mirroring of the flag.

Michal,
although the above is true i'd say it's a bit of an overkill:
RX VLAN stripping is configured in a function level, so keeping it in a per 
queue level is not needed. 

The problem u were trying to resolve (and u resolved it) was to separate the 
RX_VLAN_ENABLED flag semantics into two: requested feature and HW configured 
feature in order to further check the second in the fast path, while setting 
the first one in the set_features(). Then the second lag is updated according 
to the first one during the loading of the function (bnx2x_nic_load()).

Therefore it would be enough to just add those two flags in the function (bp) 
level keeping the rest of your patch as it is. This would also cancel the need 
for a patch 6.

Thanks,
vlad
