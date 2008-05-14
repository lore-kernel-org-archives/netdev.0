From: Jeff Garzik <jeff@garzik.org>
Subject: Re: POHMELFS high performance network filesystem. Transactions, failover,
 performance.
Date: Wed, 14 May 2008 17:34:22 -0400
Message-ID: <482B5ADE.305@garzik.org>
References: <20080513174523.GA1677@2ka.mipt.ru> <4829E752.8030104@garzik.org> <20080513205114.GA16489@2ka.mipt.ru> <Pine.LNX.4.64.0805140623001.14334@cobra.newdream.net> <20080514135156.GA23131@2ka.mipt.ru> <20080514143105.GB14987@shareable.org> <20080514150052.GA15826@2ka.mipt.ru> <482B3899.9070008@garzik.org> <20080514193234.GA10165@2ka.mipt.ru> <482B4D80.5080808@garzik.org> <20080514211919.GA13513@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamie Lokier <jamie@shareable.org>, Sage Weil <sage@newdream.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53628 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752939AbYENVe0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2008 17:34:26 -0400
In-Reply-To: <20080514211919.GA13513@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov wrote:
> Well, that's how things exist today - POHMELFS client connects to number
> of servers and can send data to all of them (currently it doest that for
> only 'active' server, i.e. that which was not failed, but that can be
> trivially changed). It should be extended to receive 'add/remove server
> to the group' command and liekly that's all (modulo other todo items
> which are not yet resolved). Then that group becomes quorum and client
> has to get response from them. Kind of that...
> 
> What I do not like, is putting lots of logic into client, like following
> inner server state changes (sync/not sync, quorum election and so on).
> With above dumb scheme it should not, but some other magic in the server
> land will tell client with whom to start working.


The client need not (and should not) worry about quorum, elections or 
server cloud state management.  The client need only support these 
basics: some method of read balancing, parallel data writes, and a 
method to retrieve a list of active servers.

The server cloud and/or cluster management can handle the rest, 
including telling the client if the transaction failed or succeeded (as 
it must), or if it should store to additional replicas before the 
transaction may proceed.

	Jeff



