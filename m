From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH] sit: correct IP protocol used in ipip6_err
Date: Thu, 16 Jun 2016 17:34:28 +0900
Message-ID: <20160616083426.GA31961@vergenet.net>
References: <1466064379-32355-1-git-send-email-simon.horman@netronome.com>
 <20160616081009.GA32730@vergenet.net>
 <576261F1.20007@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34024 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751246AbcFPIfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 04:35:03 -0400
Received: by mail-pa0-f52.google.com with SMTP id bz2so16182772pad.1
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 01:34:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <576261F1.20007@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 16, 2016 at 05:23:13PM +0900, YOSHIFUJI Hideaki wrote:
> Hi, Simon,
> 
> Simon Horman wrote:
> > On Thu, Jun 16, 2016 at 05:06:19PM +0900, Simon Horman wrote:
> >> Since 32b8a8e59c9c ("sit: add IPv4 over IPv4 support")
> >> ipip6_err() may be called for packets whose IP protocol is
> >> IPPROTO_IPIP as well as those whose IP protocol is IPPROTO_IPV6.
> >>
> >> In the case of IPPROTO_IPIP packets the correct protocol value is not
> >> passed to ipv4_update_pmtu() or ipv4_redirect().
> >>
> >> This patch resolves this problem by using the IP protocol of the packet
> >> rather than a hard-coded value. This appears to be consistent
> >> with the usage of the protocol of a packet by icmp_socket_deliver()
> >> the caller of ipip6_err().
> >>
> >> I was able to exercise the redirect case by using a setup where an ICMP
> >> redirect was received for the destination of the encapsulated packet.
> >> However, it appears that although incorrect the protocol field is not used
> >> in this case and thus no problem manifests.  On inspection it does not
> >> appear that a problem will manifest in the fragmentation needed/update pmtu
> >> case either.
> >>
> >> In short I believe this is a cosmetic fix. None the less, the use of
> >> IPPROTO_IPV6 seems wrong and confusing.
> >>
> >> Reviewed-by: Dinan Gunawardena <dinan.gunawardena@netronome.com>
> >> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> > 
> > Apologies for not making this more obvious, this is a "net-next" patch.
> 
> Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> BTW, we should have similar fix in -net, -stable etc. as well, no?

I am not opposed to this patch going there and probably it can do so
verbatim but I haven't found any run-time problems resolved by the patch.
