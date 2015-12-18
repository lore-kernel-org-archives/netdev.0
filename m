From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH][iproute2] tc/q_htb.c: Fix the MPU value output in 'tc -d
 class show dev <device_name> ' command
Date: Fri, 18 Dec 2015 17:55:18 +0100
Message-ID: <20151218165518.GE19288@orbyte.nwl.cc>
References: <5917221449918579@web5j.yandex.ru>
 <20151216161558.265296c7@redhat.com>
 <20151216160400.GJ6555@orbit.nwl.cc>
 <1313271450456765@web7g.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Dmitrii Shcherbakov <fw.dmitrii@yandex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:57654 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932264AbbLRQzU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Dec 2015 11:55:20 -0500
Content-Disposition: inline
In-Reply-To: <1313271450456765@web7g.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 18, 2015 at 07:39:25PM +0300, Dmitrii Shcherbakov wrote:
> > Dmitrii, did iproute2 without your change even print the overhead as set
> > by you before? Looking at the code, I'd assume not.
> 
> Tried building iproute2 (as of tag 4.2) and using the upstream linux kernel (also tag 4.2 - 64291f7db5bd8150a74ad2036f1037e6a0428df2):

This is without your patch, right?

[...]

> ~/src/iproute2/tc$ sudo ./tc class add dev eth0 parent 1: classid 1:1 htb rate 100kbps ceil 100kbps mpu 256 overhead 64

Setting an mpu of 256 is suitable to get 0 as output value, as the code
before your patch ANDs it with 0xff.

> So it looks like the overhead is being set correctly, but the mpu is not, even though the respective kernel module is loaded judging by what I see.

To really know what is being set, you would have to look at the kernel
variables not what iproute prints. This is nitpicking mostly, but
relevant in this case as your patches to fix iproute's output show.

Cheers, Phil
