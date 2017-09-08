From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH iproute2 0/2] malloc correct buff at run time
Date: Fri, 8 Sep 2017 14:03:54 +0200
Message-ID: <20170908120354.kyilhhujqkxmgsfc@unicorn.suse.cz>
References: <1504865697-27274-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Phil Sutter <phil@nwl.cc>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:34868 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751577AbdIHMDz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 8 Sep 2017 08:03:55 -0400
Content-Disposition: inline
In-Reply-To: <1504865697-27274-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 08, 2017 at 06:14:55PM +0800, Hangbin Liu wrote:
> With commit 72b365e8e0fd ("libnetlink: Double the dump buffer size") and
> 460c03f3f3cc ("iplink: double the buffer size also in iplink_get()"), we
> extend the buffer size to avoid truncated message with large numbers of
> VFs. But just as Michal said, this is not future-proof since the NIC
> number is increasing. We have customer even has 220+ VFs now.

This sounds like the moment we hit the bigger problem with
IFLA_VFINFO_LIST is closer than I thought. The info block for one VF is
already 236 bytes long (or was in 4.4) so that 278 VFs would be over the
natural limit for IFLA_VFINFO_LIST attribute given by 16-bit nla_len
field.

> This is not make sense to hard code the buffer and increase it all the time.
> So let's just malloc the correct buff size at run time.
> 
> I'm not sure what init size would be suitable, so I keep use the original
> size. I have tried with a small size like 1024, and it also works.

I don't think it's that important as the command usually runs only for
short time so allocating a 32KB buffer even if we could do with less is
not a big issue. (I didn't really like the idea of a 32KB buffer on
stack but with malloc() it's OK, I would say.)

Michal Kubecek
