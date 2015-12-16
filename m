From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH][iproute2] tc/q_htb.c: Fix the MPU value output in 'tc -d
 class show dev <device_name> ' command
Date: Wed, 16 Dec 2015 17:04:00 +0100
Message-ID: <20151216160400.GJ6555@orbit.nwl.cc>
References: <5917221449918579@web5j.yandex.ru>
 <20151216161558.265296c7@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitrii Shcherbakov <fw.dmitrii@yandex.com>,
	netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:36716 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751703AbbLPQEE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2015 11:04:04 -0500
Content-Disposition: inline
In-Reply-To: <20151216161558.265296c7@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 16, 2015 at 04:15:58PM +0100, Jesper Dangaard Brouer wrote:
> When trying to understand this code, keep in mind that we are trying
> to keep backward compatible with older kernels.  Thus, this printing
> might be have been left here to keep compat with older kernels, but I
> think we can remove it now.

For a given kernel which still uses the upper eight bits of 'mpu' as
overhead value, iproute2 has become incompatible since commit
bccd014b866da ("Overhead calculation is now done in the kernel.") as
that eliminated the encoding while setting. So in order to stay
compatible, it should have left it in place while assigning to
opt.*.overhead in addition to that. Or the other way round, do the same
change to the output path as well.

So from a compatibility point of view, things are incompatible anyway.
Nobody complained, so I'd assume there are no users requiring this
(anymore). In fact, I couldn't even find the related change from using
'mpu>>8' to 'overhead' on kernel side.

Dmitrii, did iproute2 without your change even print the overhead as set
by you before? Looking at the code, I'd assume not.

Cheers, Phil
