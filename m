From: Mel Gorman <mgorman@suse.de>
Subject: Re: SOCK_MEMALLOC vs loopback
Date: Thu, 5 Mar 2015 09:50:44 +0000
Message-ID: <20150305095044.GR3087@suse.de>
References: <CAOi1vP8tJTMhbCyKVD66pc_Tz7+aOS236KgvQnA-S63yv1P-sA@mail.gmail.com>
 <20150304200427.GQ3087@suse.de>
 <54F7D5A7.1060404@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Ilya Dryomov <idryomov@gmail.com>, ceph-devel@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Sage Weil <sage@redhat.com>, NeilBrown <neilb@suse.de>,
	netdev@vger.kernel.org
To: Mike Christie <mchristi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:52933 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932147AbbCEJuu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 04:50:50 -0500
Content-Disposition: inline
In-Reply-To: <54F7D5A7.1060404@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 04, 2015 at 10:03:51PM -0600, Mike Christie wrote:
> On 03/04/2015 02:04 PM, Mel Gorman wrote:
> > other options. If that contract is not met then using it can deadlock the
> > system. It's the same for PF_MEMALLOC -- activating that is a recipe for
> > deadlock due to memory exhaustion.
> 
> For rbd and iscsi's SOCK_MEMALLOC/PF_MEMALLOC use, I copied what you did
> for nbd in commit 7f338fe4540b1d0600b02314c7d885fd358e9eca which always
> sets those flags and seems to rely on the network layer to do the right
> thing. Are they all incorrect?

NBD is a poor example and if it comes to that, I would suggest removing it
and let NBD easily deadlock like it used to. NBD has other failure cases
such as the client can get paged out if -swap is not specified. The same
commit notes that NBD may still deadlock and that min_free_kbytes may have
to be increased.

-- 
Mel Gorman
SUSE Labs
