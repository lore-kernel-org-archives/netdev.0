From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next 1/8] bridge: bridge port parameters over
 netlink
Date: Wed, 31 Oct 2012 14:30:20 -0700
Message-ID: <20121031143020.62e08062@s6510.linuxnetplumber.net>
References: <20121030005731.843020405@vyatta.com>
	<20121030005835.289407930@vyatta.com>
	<50912F4D.2090602@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56086 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932661Ab2JaVac (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2012 17:30:32 -0400
In-Reply-To: <50912F4D.2090602@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 31 Oct 2012 07:01:49 -0700
John Fastabend <john.r.fastabend@intel.com> wrote:

> On 10/29/2012 5:57 PM, Stephen Hemminger wrote:
> > Expose bridge port parameters over netlink. By switching
> > from a single byet to a nested message, this can be used for
> > other bridge parameters.
> >
> > Although, this changes IFLA_PROTINFO attribute from one byte to a full nested
> > set of attributes; it is safe for applications because the
> > old message used IFLA_PROTINFO and new one uses
> >   IFLA_PROTINFO | NLA_F_NESTED.
> >
> > The code still accepts to old format requests, and therefore stays
> > compatiable with user mode RSTP daemon. Since the type field
> > for nested and unnested attributes are different, and the old
> > code in libnetlink doesn't do the mask, it is also safe to use
> > with old versions of bridge monitor command.
> >
> > Note: although mode is only a boolean, treating it as a
> > full byte since in the future someone will probably want to add more
> > values (like macvlan has).
> >
> > Signed-off-by: Stephen Hemminger<shemminger@vyatta.com>
> >
> > ---
> 
> Stephen,
> 
> Did you see these two patches
> 
> http://patchwork.ozlabs.org/patch/193900/
> http://patchwork.ozlabs.org/patch/193901/
> 
> here I added nested bridge attributes to IFLA_AF_SPEC and pass them down
> to the drivers as needed. Should we merge these two sets so that we have
> only a single nested set of bridge attributes? Either in IFLA_AF_SPEC or
> IFLA_PROTINFO.
> 
> The attributes in this patch are port specifics and the one in the
> patches listed above are bridge specific so in this sense perhaps
> its OK to keep them separate. I'm not sure it matters much either
> way but thought I would mention it.
> 
> Also I suspect these two series will have conflicts but I haven't tried
> yet.
> 
> Thanks,
> John

This is an area where there is no clear choice.
I would like to keep AF_UNSPEC for non-protocol stuff,
that is why I targeted PF_BRIDGE:IFLA_PROTINFO.

Other alternative would be to add sysctl which is less message
based, but is more general. (ie. /default and /all are available).
