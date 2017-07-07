From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH v2 RFC 0/13] Remove UDP Fragmentation Offload support
Date: Fri, 7 Jul 2017 14:45:31 +0200
Message-ID: <20170707124531.GA15765@unicorn.suse.cz>
References: <20170707.104326.2165746493532974466.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, willemdebruijn.kernel@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:51675 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752264AbdGGMpd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Jul 2017 08:45:33 -0400
Content-Disposition: inline
In-Reply-To: <20170707.104326.2165746493532974466.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 07, 2017 at 10:43:26AM +0100, David Miller wrote:
> 
> This is an RFC patch series, based upon some discussions with
> various developers, that removes UFO offloading.
> 
> Very few devices support this operation, it's usefullness is
> quesitonable at best, and it adds a non-trivial amount of
> complexity to our data paths.

My understanding from the communication with the customer whose reports
resulted in commits acf8dd0a9d0b ("udp: only allow UFO for packets from
SOCK_DGRAM sockets") and a5cb659bbc1c ("net: account for current skb
length when deciding about UFO") was that the real benefit from UFO is 
in the case when UFO allows to avoid the need to actually fragment the 
packets. In their case it's when UDP packets are sent via virtio_net 
either between a guest and its host or between two guests on the same 
host.

Personally I have no idea how big the effect is in their use cases so 
I forwarded the link to your series to them and asked them to provide 
some real life data if they want to step in. If there is no significant
performance benefit even in this case, I would agree the feature is not
worth the hassle - if nothing else, the ever growing list of exceptions
in ip{,6}_append_data() is getting out of hands.

                                                         Michal Kubecek
