From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] net: netlink: filter particular protocols from
 analyzers
Date: Thu, 5 Sep 2013 11:57:55 -0700
Message-ID: <20130905115755.7aec533c@nehalam.linuxnetplumber.net>
References: <1378396127-8342-1-git-send-email-dborkman@redhat.com>
	<20130905.144442.2085221662776542385.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org, dborkmann@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:56394 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756072Ab3IES57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 14:57:59 -0400
Received: by mail-pd0-f169.google.com with SMTP id r10so2225339pdi.28
        for <netdev@vger.kernel.org>; Thu, 05 Sep 2013 11:57:58 -0700 (PDT)
In-Reply-To: <20130905.144442.2085221662776542385.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 05 Sep 2013 14:44:42 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Thu,  5 Sep 2013 17:48:47 +0200
> 
> > From: Daniel Borkmann <dborkmann@redhat.com>
> > 
> > Fix finer-grained control and let only a whitelist of allowed netlink
> > protocols pass, in our case related to networking. If later on, other
> > subsystems decide they want to add their protocol as well to the list
> > of allowed protocols they shall simply add it. While at it, we also
> > need to tell what protocol is in use otherwise BPF_S_ANC_PROTOCOL can
> > not pick it up (as it's not filled out).
> > 
> > Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> 
> This takes away functionality that I'd be more interesting in using,
> namely being able to listen to all netlink protocols using one tap.
> 
> Seriously, when I first saw this feature, that was the first way I'd
> imagine myself using it, as a tcpdump for netlink traffic, all of
> it.
> 
> If I just want to hear all netlink traffic, don't make me be forced to
> know every single NETLINK_* protocol value and have to open that many
> sockets just to do so.
> 
> It also makes it so that I can't listen to userlevel custom netlink
> protocols, another minus of filtering.
> 
> At the very least, allow an sk_protocol of zero or similar to have this
> meaning of "everything".
> 
> I'm not applying this patch, sorry.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


If you want filtering, why not add BPF (sk_filter) support to this?
