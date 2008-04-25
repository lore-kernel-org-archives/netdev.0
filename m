From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit kernels.
Date: Thu, 24 Apr 2008 23:23:15 -0700
Message-ID: <OF6BB885BC.24376BB7-ON88257436.0021B953-88257436.002315D4@us.ibm.com>
References: <20080425.143845.24767700.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, yoshfuji@linux-ipv6.org
To: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:39202 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755495AbYDYGXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 02:23:35 -0400
In-Reply-To: <20080425.143845.24767700.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 04/24/2008 10:38:45 PM:

> In article 
<OF3A37018B.9EFE360C-ON88257435.00614684-88257435.00622448@us.ibm.
> com> (at Thu, 24 Apr 2008 11:52:01 -0600), David Stevens 
<dlstevens@us.ibm.com> says:
> 
> >  #ifdef CONFIG_COMPAT
> > +
> > +struct compat_group_req {
> > +       __u32                                   gr_interface;
> > +       struct __kernel_sockaddr_storage        gr_group;
> > +} __attribute__ ((packed));
> > +
> :
> 
> I prefer __compat_sockaddr_storage{} which has definition closer to
> one on 32bit platform.  "packed" seems overkill to me.

        Yes, I saw the discussion you and Dave had. I think it ought to be
at least a local-use declaration with these, rather than in a header. For
these 32-bit ints that are being aligned in this case, the effect is
exactly the same, so I don't object.

> Unfortunately this cannot work.
> __copy_tofrom_user is not available on x86_64 etc.

        I don't know if there is a standard user-user copy
available for these. I wanted to allocate the copy on the
user stack to avoid allocating a temporary kernel buffer and
resetting the segment, but I prefer any approach where the
compatibility portion is done in the compat wrapper without
modification to non-compat code. That approach also has the
advantage of allowing the same wrapper to work with both
v6 and v4.

                                                        +-DLS

