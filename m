From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: [PATCH] ipv6: fix signedness of tmp_prefered_lft underflow check
Date: Wed, 19 Oct 2016 15:16:36 +0200
Message-ID: <20161019131636.zhusbqh63qlbq5vy@dwarf.suse.cz>
References: <alpine.DEB.2.20.1610151945380.9280@hadrien>
 <20161018150154.4tpivtvxygp7kjpd@dwarf.suse.cz>
 <20161018.142525.1262217492229127435.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
        kbuild-all@01.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:41531 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S942297AbcJSOds (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Oct 2016 10:33:48 -0400
Content-Disposition: inline
In-Reply-To: <20161018.142525.1262217492229127435.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Oct 18, 2016 at 02:25:25PM -0400, David Miller wrote:
> Does the check make any sense at all?  I'd say just remove it.

The purpose was to guard against the user updating the
temp_prefered_lft sysctl after this:

        max_desync_factor = min_t(__u32,
                                  idev->cnf.max_desync_factor,
                                  idev->cnf.temp_prefered_lft - regen_advance);

but before this:

	tmp_prefered_lft = idev->cnf.temp_prefered_lft + age -
			    idev->desync_factor;


With enough bad luck, tmp_prefered_lft could underflow and the resulting
preferred lifetime could be almost infinity.

On the other hand, with this check, this situation will result
with the temporary address not being created at all, which might
be even worse. So if you prefer it, just drop the check.
Patch in a follow-up e-mail.

Thanks,

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
