From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Possible problem with e6afc8ac ("udp: remove headers from UDP
 packets before queueing")
Date: Thu, 02 Jun 2016 14:44:10 -0700
Message-ID: <1464903850.5939.178.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAHC9VhS0oH8p55_3yOcQGJWx8WmokHW=kSrKOM6tKPM1XoPjGA@mail.gmail.com>
	 <1464808695.5939.167.camel@edumazet-glaptop3.roam.corp.google.com>
	 <0b1fde4f-57ef-8c5e-147f-10c4a51fb2b0@tycho.nsa.gov>
	 <CAHC9VhQAiTRWMN-vNDXgAni2MhsyEYP8f2mZDY63xrx=5SxenQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: samanthakumar@google.com, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	Stephen Smalley <sds@tycho.nsa.gov>
To: Paul Moore <paul@paul-moore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35954 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161009AbcFBVoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 17:44:15 -0400
In-Reply-To: <CAHC9VhQAiTRWMN-vNDXgAni2MhsyEYP8f2mZDY63xrx=5SxenQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-06-02 at 17:36 -0400, Paul Moore wrote:
> On Wed, Jun 1, 2016 at 4:44 PM, Stephen Smalley <sds@tycho.nsa.gov> wrote:
> > On 06/01/2016 03:18 PM, Eric Dumazet wrote:
> >> On Wed, 2016-06-01 at 15:01 -0400, Paul Moore wrote:
> >>> Hello,
> >>>
> >>> I'm currently trying to debug a problem with 4.7-rc1 and labeled
> >>> networking over UDP.  I'm having some difficulty with the latest
> >>> 4.7-rc1 builds on my test system at the moment so I haven't been able
> >>> to concisely identify the problem, but looking through the commits in
> >>> 4.7-rc1 I think there may be a problem with the following:
> >>>
> >>>   commit e6afc8ace6dd5cef5e812f26c72579da8806f5ac
> >>>   Author: samanthakumar <samanthakumar@google.com>
> >>>   Date:   Tue Apr 5 12:41:15 2016 -0400
> >>>
> >>>    udp: remove headers from UDP packets before queueing
> >>>
> >>>    Remove UDP transport headers before queueing packets for reception.
> >>>    This change simplifies a follow-up patch to add MSG_PEEK support.
> >>>
> >>>    Signed-off-by: Sam Kumar <samanthakumar@google.com>
> >>>    Signed-off-by: Willem de Bruijn <willemb@google.com>
> >>>    Signed-off-by: David S. Miller <davem@davemloft.net>
> >>>
> >>> ... it appears that this commit changes things so that sk_filter() is
> >>> only called when sk->sk_filter is not NULL.  While this is fine for
> >>> the traditional socket filter case, it causes problems with LSMs that
> >>> make use of security_sock_rcv_skb() to enforce per-packet access
> >>> controls.
> >>>
> >>> Hopefully I'll get 4.7-rc1 booting soon and I can do a proper
> >>> bisection test around this patch, but I wanted to mention this now in
> >>> case others are seeing the same problem.
> >>
> >> Thanks for the report. Please try following fix.
> >>
> >> sk_filter() got additional features like the skb_pfmemalloc() things and
> >> security_sock_rcv_skb()
> >
> > This resolved the SELinux regression for me.
> >
> > Tested-by: Stephen Smalley <sds@tycho.nsa.gov>
> 
> The patch works for me too.  Eric, are you going to send this to DaveM
> (assuming he isn't listening in on this thread and picking it up
> himself)?
> 
> Tested-by: Paul Moore <paul@paul-moore.com>

I am going to send the official patch right away, thanks !
