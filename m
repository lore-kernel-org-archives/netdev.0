From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: Can libpcap filter on vlan tags when vlans are
 hardware-accelerated?
Date: Tue, 12 Sep 2017 22:26:17 +0200
Message-ID: <20170912202617.ny3bbi2dthxxffh3@unicorn.suse.cz>
References: <51a124d5-8a5f-35d4-5242-fd8a289f50b5@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:42766 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750742AbdILU0T (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 12 Sep 2017 16:26:19 -0400
Content-Disposition: inline
In-Reply-To: <51a124d5-8a5f-35d4-5242-fd8a289f50b5@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 12, 2017 at 11:54:43AM -0700, Ben Greear wrote:
> It does not appear to work on Fedora-26, and I'm curious if someone
> knows what needs doing to get this support working?

It's rather complicated. The "vlan" and "vlan <id>" filters didn't
handle the case when vlan information is passed in metadata until commit
04660eb1e561 ("Use BPF extensions in compiled filters"), i.e. libpcap
1.7.0. Unfortunately that commit made libpcap always check only metadata
for the first outermost vlan tag so that it broke the case when vlan
information is passed in packet itself (which is less frequent today).

To handle both cases correctly, you would need libpcap with commits
d739b068ac29 ("Make VLAN filter handle both metadata and inline tags")
and 7c7a19fbd9af ("Fix logic of combined VLAN test") and also the
optimizer fix from

  https://github.com/the-tcpdump-group/libpcap/pull/582/commits/075015a3d17a

(without it the filters generate incorrect BPF in some cases unless the
optimizer is disabled). As far as I can see, these commits are not in
any release yet.

                                                       Michal Kubecek
