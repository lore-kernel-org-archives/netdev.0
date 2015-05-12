From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] Revert "ipv6: Allow for partial checksums on
 non-ufo packets"
Date: Tue, 12 May 2015 12:07:38 -0700
Message-ID: <1431457658.566.91.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1770409.aMESoOv08f@h2o.as.studentenwerk.mhn.de>
	 <1431002384.22756.0.camel@edumazet-glaptop2.roam.corp.google.com>
	 <12346713.ZyFExCo3ux@h2o.as.studentenwerk.mhn.de>
	 <2088438.42IY8hjjd5@h2o.as.studentenwerk.mhn.de>
	 <1431122268.22756.41.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1431123765.22756.51.camel@edumazet-glaptop2.roam.corp.google.com>
	 <555240F4.4070406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wolfgang Walter <linux@stwm.de>, netdev <netdev@vger.kernel.org>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:35150 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751470AbbELTHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 15:07:40 -0400
Received: by igbyr2 with SMTP id yr2so117743743igb.0
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 12:07:40 -0700 (PDT)
In-Reply-To: <555240F4.4070406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-05-12 at 14:05 -0400, Vlad Yasevich wrote:
> On 05/08/2015 06:22 PM, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Wolfgang Walter reported crashes using traceroute6, root caused to this
> > commit.
> > 
> > UDP packets can be sent from RAW sockets.
> > 
> > Note that the faulty commit addressed a non problem, as normal
> > UDP v6 packets use udp_v6_send_skb() which correctly setup
> > CHECKSUM_PARTIAL properly if device has the correct feature.
> 
> Actually, they didn't.  udp_v6_send_skb() uses ip_summed from
> the skb, which is populated by __ip6_append_data.  That in turn
> always set it CHECKSUM_NONE.
> 
> The code in question looks identically to that of __ip_append_data().
> The problem is similar in both places.

Well, one is crashing the host. IPv4 raw must have been OK, not IPv6.

As I explained in the changelog, you can try to fix
rawv6_push_pending_frames()

My opinion is that a reasonable strategy is to revert for stable
kernels.

Then if you can fix rawv6_push_pending_frames() for net-next, I will be
happy to review your patch.
