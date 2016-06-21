From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH v2 2/7] Use C99 style initializers everywhere
Date: Tue, 21 Jun 2016 19:03:33 +0200
Message-ID: <20160621170333.GD19797@orbyte.nwl.cc>
References: <1466525921-15738-1-git-send-email-phil@nwl.cc>
 <1466525921-15738-3-git-send-email-phil@nwl.cc>
 <726e5c7d-f23b-dbf0-c1d4-721ef3d15d5b@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemming@brocade.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>, netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:45757 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932244AbcFURDg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2016 13:03:36 -0400
Content-Disposition: inline
In-Reply-To: <726e5c7d-f23b-dbf0-c1d4-721ef3d15d5b@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 21, 2016 at 10:24:37AM -0600, David Ahern wrote:
> On 6/21/16 10:18 AM, Phil Sutter wrote:
> > This big patch was compiled by vimgrepping for memset calls and changing
> > to C99 initializer if applicable. One notable exception is the
> > initialization of union bpf_attr in tc/tc_bpf.c: changing it would break
> > for older gcc versions (at least <=3.4.6).
> >
> > Calls to memset for struct rtattr pointer fields for parse_rtattr*()
> > were just dropped since they are not needed.
> >
> > The changes here allowed the compiler to discover some unused variables,
> > so get rid of them, too.
> >
> > Signed-off-by: Phil Sutter <phil@nwl.cc>
> > ---
> > Changes since v1:
> > - Dropped former changes to tc/tc_bpf.c as they are incompatible to older
> >   gcc versions (at least <=3.4.6).
> 
> 
> What OS versions have you compiled iproute2 against?

Tested on Gentoo with old compiler installed, so apart from gcc the
system is up to date.

> I downloaded CentOS 5 and 6. iproute2 fails to compile on CentOS 5.11; 
> ip command builds on 6.8 but with a flurry of redefinition errors 
> (BUILD_BUG_ON), but fails at tc.

What's the exact error message please? Maybe some incompatibility in
kernel headers? Although that shouldn't be ...

Cheers, Phil
