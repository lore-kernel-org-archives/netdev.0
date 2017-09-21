From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] net: introduce noref sk
Date: Wed, 20 Sep 2017 20:20:22 -0700 (PDT)
Message-ID: <20170920.202022.2073272587145961156.davem@davemloft.net>
References: <cover.1505926196.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pablo@netfilter.org, fw@strlen.de,
        edumazet@google.com, hannes@stressinduktion.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49316 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751283AbdIUDU1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 23:20:27 -0400
In-Reply-To: <cover.1505926196.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Wed, 20 Sep 2017 18:54:00 +0200

> This series introduce the infrastructure to store inside the skb a socket
> pointer without carrying a refcount to the socket.
> 
> Such infrastructure is then used in the network receive path - and
> specifically the early demux operation.
> 
> This allows the UDP early demux to perform a full lookup for UDP sockets,
> with many benefits:
> 
> - the UDP early demux code is now much simpler
> - the early demux does not hit any performance penalties in case of UDP hash
>   table collision - previously the early demux performed a partial, unsuccesful,
>   lookup
> - early demux is now operational also for unconnected sockets.
> 
> This infrastrcture will be used in follow-up series to allow dst caching for
> unconnected UDP sockets, and than to extend the same features to TCP listening
> sockets.

Like Eric, I find this series (while exciting) quite scary :-)

You really have to post some kind of performance numbers in your
header posting in order to justify something with these ramifications
and scale.

Thank you.
