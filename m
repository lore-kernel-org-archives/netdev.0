From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCHv5 iproute2 net-next 2/2] lib/libnetlink: re malloc buff
 if size is not enough
Date: Thu, 26 Oct 2017 20:31:47 +0200
Message-ID: <20171026183147.GY32305@orbyte.nwl.cc>
References: <1508982107-28474-1-git-send-email-liuhangbin@gmail.com>
 <1508982107-28474-2-git-send-email-liuhangbin@gmail.com>
 <10ef7665-b47a-881a-ab00-1e2c6c224d0b@gmail.com>
 <20171026122442.7e2ac2d0@shemminger-XPS-13-9360>
 <25f0ec07-e36a-510c-c01f-56df8a843f80@gmail.com>
 <20171026153340.GX32305@orbyte.nwl.cc>
 <4dd9b1a2-878d-dfe0-f9b7-f000fbde3c6c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Hangbin Liu <liuhangbin@gmail.com>, netdev@vger.kernel.org,
        Michal Kubecek <mkubecek@suse.cz>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:41624 "EHLO orbyte.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932309AbdJZSbu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Oct 2017 14:31:50 -0400
Content-Disposition: inline
In-Reply-To: <4dd9b1a2-878d-dfe0-f9b7-f000fbde3c6c@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 26, 2017 at 09:42:46AM -0600, David Ahern wrote:
> On 10/26/17 9:33 AM, Phil Sutter wrote:
> > On Thu, Oct 26, 2017 at 09:28:00AM -0600, David Ahern wrote:
> >> On 10/26/17 4:24 AM, Stephen Hemminger wrote:
> >>>>
> >>>> The kernel needs a flag that says "give me the message of the buffer is
> >>>> large enough; if not just PEEK and tell me the length." That would avoid
> >>>> the double call in most cases.
> >>>
> >>> Actually this has little impact because old code was doing implicit zero
> >>> of whole buffer, new code does not.
> >>>
> >>
> >> The patch calls recvmsg twice; libnl does the same thing. It would be
> >> better performance wise to have a flag that allows retrieval of the
> >> message if the supplied buffer is large enough and PEEK semantics if
> >> not. It was really a comment on how we could do better with proper
> >> kernel support.
> > 
> > Doesn't MSG_TRUNC without MSG_PEEK do just that?
> 
> MSG_TRUNC returns the actual message length if it is greater than the
> buffer. The message was dequeued and what could be copied into the
> supplied buffer is copied, but that means the returned message is truncated.

Ah, so one would have to resend the request then. Stupid me. :)

Thanks, Phil
