From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: increase size at which
 tcp_bound_to_half_wnd bounds to > TCP_MSS_DEFAULT
Date: Tue, 28 Jun 2016 13:58:10 +0200
Message-ID: <1467115090.6850.202.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CS1PR84MB0295E420892A535E40FE338EFD220@CS1PR84MB0295.NAMPRD84.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Seymour, Shane M" <shane.seymour@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:37907 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752185AbcF1L60 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 07:58:26 -0400
Received: by mail-wm0-f46.google.com with SMTP id r201so24138471wme.1
        for <netdev@vger.kernel.org>; Tue, 28 Jun 2016 04:58:17 -0700 (PDT)
In-Reply-To: <CS1PR84MB0295E420892A535E40FE338EFD220@CS1PR84MB0295.NAMPRD84.PROD.OUTLOOK.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-06-28 at 04:33 +0000, Seymour, Shane M wrote:
> In previous commit 01f83d69844d307be2aa6fea88b0e8fe5cbdb2f4
> the following comments were added:
> 
> "When peer uses tiny windows, there is no use in packetizing to sub-MSS
> pieces for the sake of SWS or making sure there are enough packets in
> the pipe for fast recovery."
> 
> The test should be > TCP_MSS_DEFAULT not >= 512. This allows low end
> devices that send an MSS of 536 (TCP_MSS_DEFAULT) to see better network
> performance by sending it 536 bytes of data at a time instead of bounding
> to half window size (268). Other network stacks work this way, e.g. HP-UX.


Trying to cope with ridiculous windows these days is really a waste of
time, as we perform this check for all tcp sendmsg() calls :(

Anyway, your patch is reversed.
