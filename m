From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] inetpeer: Add support for VRFs
Date: Tue, 25 Aug 2015 19:37:42 +0200
Message-ID: <20150825173742.GA3707@pox.localdomain>
References: <1440339964-16075-1-git-send-email-dsa@cumulusnetworks.com>
 <20150824001514.GD21926@pox.localdomain>
 <55DA7AFE.5040301@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:35833 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400AbbHYRho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 13:37:44 -0400
Received: by wicne3 with SMTP id ne3so22107251wic.0
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 10:37:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <55DA7AFE.5040301@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/23/15 at 08:01pm, David Ahern wrote:
> On 8/23/15 6:15 PM, Thomas Graf wrote:
> >On 08/23/15 at 08:26am, David Ahern wrote:
> >>inetpeer caches based on address only, so duplicate IP addresses within
> >>a namespace return the same cached entry. Similar to IP fragments handle
> >>duplicate addresses across VRFs by adding the VRF master device index to
> >>the lookup.
> >
> >We have a lot of other places which use the address only. Are you
> >going to add the VRF id to all these places as well?
> >
> 
> If appropriate, yes. I have fixed IP fragments and this patch fixes inetpeer
> cache. In both cases (L3 artifacts) the vrf device index provides the means
> to uniquely identify duplicate IP addresses within a namespace. If you know
> of other code that might be impacted I will investigate and fix as needed.

OK, then the question is what do you consider appropriate? ;-) An obvious
example is netfilter conntrack but eventually any decision based on an
address would require the VRF id if you want to go all the way.

I see the advantages over netns based VRF right now due to the lightweight
nature but if this turns out to require a new field in practically every
address datastructure then that seems not what we want.
