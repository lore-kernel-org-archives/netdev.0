From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next iproute2 1/3] netlink: import netlink message
 parsing from kernel
Date: Tue, 2 May 2017 14:20:48 -0700
Message-ID: <20170502142048.62670dc7@xeon-e3>
References: <1493695105-9418-1-git-send-email-dsa@cumulusnetworks.com>
        <1493695105-9418-2-git-send-email-dsa@cumulusnetworks.com>
        <20170502124925.5276665e@xeon-e3>
        <91687d1a-0187-9e30-911b-f752af1c3be6@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jakub.kicinski@netronome.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:33497 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750710AbdEBVUy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 17:20:54 -0400
Received: by mail-pg0-f54.google.com with SMTP id y4so62165750pge.0
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 14:20:53 -0700 (PDT)
In-Reply-To: <91687d1a-0187-9e30-911b-f752af1c3be6@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2 May 2017 14:39:40 -0600
David Ahern <dsa@cumulusnetworks.com> wrote:

> On 5/2/17 1:49 PM, Stephen Hemminger wrote:
> > I am not disagreeing that iproute2 should handle the extended
> > error format. Just want the solution to be as small as possible;
> > ie do no more than is absolutely necessary. And future proof
> > for the inevitable growth in new area.  
> 
> Understood. I was trying to not reinvent a wheel. nla_parse and
> nla_validate have not really been touched in 10 years, and both are well
> written with a good API to the rest of the code base.
> 
> From there, I grabbed whole snippets as opposed to just taking what is
> needed for the ext-ack feature. I left the name as nlattr.c for easy
> diff if future code is wanted. The header file was renamed to nlattr.h
> to avoid confusion with other netlink.h files. Not adding it to
> libnetlink.h facilitates pulling more code via diff as needed.
> 
> In short, I think it is good to re-use code from the kernel (lib and
> tools/lib) where possible and doing so in a way that makes updates as
> easy as header files.

The problem with copy and paste is that the code diverges and rots.
Also the security and error model in user space are different

> >   
> >> +
> >> +static const __u8 nla_attr_minlen[NLA_TYPE_MAX+1] = {
> >> +	[NLA_U8]	= sizeof(__u8),
> >> +	[NLA_U16]	= sizeof(__u16),
> >> +	[NLA_U32]	= sizeof(__u32),
> >> +	[NLA_U64]	= sizeof(__u64),
> >> +	[NLA_MSECS]	= sizeof(__u64),
> >> +	[NLA_NESTED]	= NLA_HDRLEN,
> >> +	[NLA_S8]	= sizeof(__s8),
> >> +	[NLA_S16]	= sizeof(__s16),
> >> +	[NLA_S32]	= sizeof(__s32),
> >> +	[NLA_S64]	= sizeof(__s64),
> >> +};
> >> +  
> > 
> > This patch makes iproute2 now doing validation of netlink attributes
> > coming back from the kernel. What is the point, userspace should be
> > trusting the kernel.  
> 
> The kernel has bugs too; userspace should verify what it sends. In this
> case the policy validation is just data types -- a string was expected
> and a string was returned, or an attribute should be a u32 and it is.
> You can argue it is overkill for iproute2, but it is good coding practice.
> 
> And for many netlink based features iproute2 tends to be the model that
> is copied into other code bases.

Then why only for new code.

I am not trying to be overly picky. Just that review is the time to play
devil's advocate and look for issues.
