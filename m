From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC 0/3] netlink: extended error reporting
Date: Fri, 07 Apr 2017 21:26:35 +0200
Message-ID: <1491593195.5800.11.camel@sipsolutions.net>
References: <20170407182620.6438-1-johannes@sipsolutions.net>
         <20170407.115315.23470877439489670.davem@davemloft.net>
         <1491591552.5800.1.camel@sipsolutions.net>
         <20170407.122053.201153373954521345.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        pablo@netfilter.org, jiri@resnulli.us
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:51828 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933841AbdDGT0k (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 15:26:40 -0400
In-Reply-To: <20170407.122053.201153373954521345.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-04-07 at 12:20 -0700, David Miller wrote:

> But what it lacks fundamentally is context.  Therefore it can't be
> used to provide the offset or the bad attribute number.  So it can't
> meet our requirements.

Yes, it doesn't address the requirements here, and in a sense I suspect
this will be true anywhere else too - perhaps that's the reason why it
was never applied even over in perf. I've not gotten a good answer for
that question yet :)

> We've passed down new arguments into core method call chains for much
> less useful facilitites than this.  So that doesn't bother me.  And
> as that is a kernel internal matter, we can refine it later.

Yes, both are true.

> Wrt. nla_parse(), we can solve that problem as follow-on patches too.

Yes. I just want to be sure we can solve it, but OTOH we're not locking
down anything but the UAPI so whatever way we find to solve it, even if
it requires a complete rearchitecture internally, it still doesn't
matter.

> So I consider this change ready as far as the implementation is
> concerned.

Fair enough. I still do need to test it though :)

> Ok, Jiri, start reading.  I will try to make you happy here.
> 
> Let's just discuss the UAPI, since people complain we don't talk
> about that enough :-)  For those playing at home it is three new
> attributes returned in a netlink ACK when the application asks
> for the extended response:
> 
>         NLMSGERR_ATTR_MSG       string  Extended error string
>         NLMSGERR_ATTR_OFFS      u32     Byte offset to netlink
> element causing error
>         NLMSGERR_ATTR_CODE      u32     Subsystem specific error code
>         NLMSGERR_ATTR_ATTR      u16     Netlink attribute triggering
> error or missing

That's four ;-)

Since you're carefully listing it here, you should also say that

 * the new behaviour is entirely optional, enabled by a new netlink
   socket option
 * the ACK message format ends up being
   [nlmsg header]
   [ack header including errno]
   [request message nlmsg hdr]
   [request message payload - optional, controlled by socket option,
    aligned to 4 byte length if present]
   [new TLVs - optional, controlled by socket option]

johannes
