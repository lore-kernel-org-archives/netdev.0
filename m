From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Patch net-next v1 3/4] vxlan: add ipv6 support
Date: Mon, 1 Apr 2013 08:36:16 -0700
Message-ID: <20130401083616.1f9d9645@nehalam.linuxnetplumber.net>
References: <1364708625-29063-1-git-send-email-amwang@redhat.com>
	<1364708625-29063-3-git-send-email-amwang@redhat.com>
	<OF5EB046E4.6295C3A5-ON85257B40.00537077-85257B40.00542577@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:42344 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758321Ab3DAPgd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Apr 2013 11:36:33 -0400
Received: by mail-pb0-f50.google.com with SMTP id jt11so1246445pbb.9
        for <netdev@vger.kernel.org>; Mon, 01 Apr 2013 08:36:32 -0700 (PDT)
In-Reply-To: <OF5EB046E4.6295C3A5-ON85257B40.00537077-85257B40.00542577@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 1 Apr 2013 11:19:10 -0400
David Stevens <dlstevens@us.ibm.com> wrote:

> netdev-owner@vger.kernel.org wrote on 03/31/2013 01:43:44 AM:
>  
> > +struct vxlan_ip {
> > +   union {
> > +      __be32  ip4;
> > +#if IS_ENABLED(CONFIG_IPV6)
> > +      struct in6_addr ip6;
> > +#endif
> > +   };
> > +   __be16          proto;
> > +};
> > +
> 
>         This looks suspiciously like a sockaddr. sockaddr_storage is
> much bigger than you need, but you could just make it a sockaddr_in6
> and cast it to sockaddr_in when needed, make it sockaddr_in6 and use
> V4_MAPPED addresses for v4, or make it a union of sockaddr_in and
> sockaddr_in6, or have a buffer the size of sockaddr_in6 and use it
> as a sockaddr to determine the family, then go from there.
>         I think anything along those lines is better than a new variant
> with the same functionality of sockaddr that isn't an overlay of a
> sockaddr.
> 
>                                                         +-DLS
> 

That is exactly what I was thinking.
