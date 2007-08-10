From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: 2.6.23-rc2-mm2
Date: Fri, 10 Aug 2007 13:54:14 -0600
Message-ID: <m1tzr7w4gp.fsf@ebiederm.dsl.xmission.com>
References: <20070809224254.11f42716.akpm@linux-foundation.org>
	<46BC8F71.3070006@googlemail.com> <46BC944F.9020801@googlemail.com>
	<m1fy2rxpje.fsf@ebiederm.dsl.xmission.com>
	<20070810124156.2de9710e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gabriel C <nix.or.die@googlemail.com>,
	Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	linux-kernel@vger.kernel.org, Netdev <netdev@vger.kernel.org>,
	coreteam@netfilter.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:50735 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934891AbXHJTyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 15:54:35 -0400
In-Reply-To: <20070810124156.2de9710e.akpm@linux-foundation.org> (Andrew
	Morton's message of "Fri, 10 Aug 2007 12:41:56 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> writes:

> On Fri, 10 Aug 2007 11:33:41 -0600
> ebiederm@xmission.com (Eric W. Biederman) wrote:
>
>> Gabriel C <nix.or.die@googlemail.com> writes:
>> 
>> > Michal Piotrowski wrote:
>> >> Andrew Morton pisze:
>> >>>
>> >
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.23-rc2/2.6.23-rc2-mm2/
>> >>>
>> >> 
>> >> Yet another sysctl table check failed
>> >> 
>> >> [   88.949055] Netfilter messages via NETLINK v0.30.
>> >> [   89.485399] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
>> >> [ 89.491892] sysctl table check failed:
>> > /net/netfilter/nf_conntrack_generic_timeout .3.19.13 Missing strategy
>> >> [   89.558178] xt_state: Unknown symbol nf_conntrack_untracked
>> >> [   89.563942] xt_state: Unknown symbol nf_ct_l3proto_module_put
>> >> [   89.569870] xt_state: Unknown symbol nf_ct_l3proto_try_module_get
>> >> [   90.852319] NET: Registered protocol family 17
>> >>
>> >
>> > And maybe this ?
>> 
>> Could be.
>> 
>> sysctl table check failure looks legitimate.
>> At a quick skim I can't tell for certain if failure to register the
>> sysctl table will keep the module from loading but it might.
>> 
>> It looks like another canidate on the pile of kill the broken
>> binary sysctl.
>> 
>
> There seems to be rather a lot of damage here.
>
> I assume that the sysctl changes are what caused the netfilter oopses.
>
> - nf_conntrack_init() calls nf_conntrack_expect_init() which fails due to
>   sysctl problems.  
>
> - nf_conntrack_init() bales out without calling nf_conntrack_helper_init()
>
>   So nf_ct_helper_hsize never gets initialised.
>
> - Later, netfilter client code calls helper_hash(), which gets a
>   divide-by-zero due to nf_ct_helper_hsize==0.
>
>
> yeah, that's a netfilter bug, but we're trying to get kernels tested here. 
> If I'm feeling energetic I'll drop the sysctl changes and do rc2-mm3. 
> Probably I won't feel energetic, but we'll need a lot of fixes here before
> I can release the sysctl changes in another -mm, please.

Under construction.

Eric

