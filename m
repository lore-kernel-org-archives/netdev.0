From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH] ipv4: FIB Local/MAIN table collapse
Date: Wed, 11 Mar 2015 07:58:49 -0700
Message-ID: <55005829.5050406@gmail.com>
References: <20150306213830.1139.16932.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, jiri@resnulli.us, sfeldma@gmail.com,
	davem@davemloft.net, sd@queasysnail.net
To: Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33821 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769AbbCKO6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 10:58:51 -0400
Received: by paceu11 with SMTP id eu11so12108271pac.1
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 07:58:51 -0700 (PDT)
In-Reply-To: <20150306213830.1139.16932.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/06/2015 01:47 PM, Alexander Duyck wrote:
> This patch is meant to collapse local and main into one by converting
> tb_data from an array to a pointer.  Doing this allows us to point the
> local table into the main while maintaining the same variables in the
> table.
>
> As such the tb_data was converted from an array to a pointer, and a new
> array called data is added in order to still provide an object for tb_data
> to point to.
>
> In order to track the origin of the fib aliases a tb_id value was added in
> a hole that existed on 64b systems.  Using this we can also reverse the
> merge in the event that custom FIB rules are enabled.
>
> With this patch I am seeing an improvement of 20ns to 30ns for routing
> lookups as long as custom rules are not enabled, with custom rules enabled
> we fall back to split tables and the original behavior.
>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> ---
>
> Changes since the RFC:
>   Added tb_id value so I could split main and local for custom rules
>   Added functionality to split tables if custom rules were enabled
>   Added table replacement and unmerge functions
>
> I have done some testing on this to verify performance gains and that I can
> split the tables correctly when I enable custom rules, but this patch is
> what I would consider to be high risk since I am certain there are things I
> have not considered.
>
> If this gets pulled into someone's switchdev tree instead of into net-next I
> would be perfectly fine with that as I am sure this can use some additional
> testing.

Has anyone out there had a chance to review this patch?  I had suggested
holding off on applying it to net-next for additional testing, but I
haven't found anything, and the only related issue is the one issue
Sabrina reported for the RTNL locking which was already in net-next anyway.

If nobody has any objections then maybe we should apply this after
Sabrina's patch and see what other bugs if any can be found when this
goes into linux-next?  I figure that since the performance gains from
this patch are fairly significant the risk is likely worth the reward.

- Alex
