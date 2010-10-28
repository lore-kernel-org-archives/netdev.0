From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] ipv6: addrconf: clear IPv6 addresses and routes when
 losing link
Date: Thu, 28 Oct 2010 15:41:13 -0700
Message-ID: <AANLkTikiWL+0h4aMv7DvouGudOCVyocuP0BvNL6_Yt+s@mail.gmail.com>
References: <AANLkTikC4pv8aOODM2pOg2bKQGL69wivcUU3f9ZziPhe@mail.gmail.com>
 <4CC78F19.9080504@hp.com> <AANLkTikTT5ie-R61rA9NucgGi5RBOPpXZLMYQRa_wb7j@mail.gmail.com>
 <AANLkTinA+znFn4txgq_2=njuX+eCTNJW+n_psbMYkU9d@mail.gmail.com>
 <AANLkTi=AyYrmSWDTZVWb2s+jgnyjNyHo-fkV4U+Fm45n@mail.gmail.com> <AANLkTim-2ghTVVEaJesMkXcRL-eCPBoHkehKF8HXhyK+@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Brian Haley <brian.haley@hp.com>
To: =?ISO-8859-2?Q?Maciej_=AFenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:23180 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758933Ab0J1Wlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 18:41:36 -0400
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id o9SMfZ61028635
	for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 15:41:35 -0700
Received: from gwj22 (gwj22.prod.google.com [10.200.10.22])
	by hpaq5.eem.corp.google.com with ESMTP id o9SMfXQ8002662
	for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 15:41:34 -0700
Received: by gwj22 with SMTP id 22so1820257gwj.11
        for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 15:41:33 -0700 (PDT)
In-Reply-To: <AANLkTim-2ghTVVEaJesMkXcRL-eCPBoHkehKF8HXhyK+@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 28, 2010 at 3:23 PM, Lorenzo Colitti <lorenzo@google.com> wrote:
> It's random, but the random interface ID is a property of the
> interface, not of the address, and thus survives interface up/down:

Also note that it's fairly trivial, instead of deleting all privacy
addresses when link is lost, to simply deprecate them so they
automatically come back after link comes back if an RA refreshes their
lifetime.

I'd rather not do this, because it introduces a brief window on link
up where the system has broken IPv6 connectivity and all connection
attempts hang for three minutes. But if this is the only alternative
to the current behaviour (where all connection attempts hang forever
until all old addresses have exhausted their lifetimes), then we can
do it.
