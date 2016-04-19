From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH net-next 7/8] net: ipv4: listified version of ip_rcv
Date: Tue, 19 Apr 2016 09:54:42 -0700
Message-ID: <1461084882.10638.193.camel@edumazet-glaptop3.roam.corp.google.com>
References: <5716338E.4050003@solarflare.com>
	 <5716347D.3030808@solarflare.com>
	 <1461077434.10638.189.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CALx6S34ZFFFZVn2_ugp+eQg6QhdHj=CWPuvW3s9aC2dg75nqiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Edward Cree <ecree@solarflare.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	linux-net-drivers@solarflare.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:36504 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754545AbcDSQyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 12:54:43 -0400
Received: by mail-pf0-f171.google.com with SMTP id e128so8493909pfe.3
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 09:54:42 -0700 (PDT)
In-Reply-To: <CALx6S34ZFFFZVn2_ugp+eQg6QhdHj=CWPuvW3s9aC2dg75nqiQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-04-19 at 08:46 -0700, Tom Herbert wrote:

> Right, this is significant complexity for a fairly narrow use case.
> One alternative might be to move early type demux like functionality
> to the GRO layer. There's a lot of work done by GRO to parse and
> identify packets of the same flow, even if we can't aggregate such
> packets it might be nice if we can at least provide a cached route so
> that we avoid doing a full route lookup on each one later on.

Moving early demux earlier in the stack would also allow us to implement
RFS more efficiently, removing one hash lookup.
(no extra cache line miss in global RFS table)
