From: Jon Maloy <jon.maloy@ericsson.com>
Subject: RE: [PATCH net-next v2 2/8] tipc: compensate for double accounting
 in socket rcv buffer
Date: Wed, 14 May 2014 17:52:50 +0000
Message-ID: <A2BAEFC30C8FD34388F02C9B3121859D1C251554@eusaamb103.ericsson.se>
References: <1400060355-26308-3-git-send-email-jon.maloy@ericsson.com>
	<1400068021.7973.78.camel@edumazet-glaptop2.roam.corp.google.com>
	<A2BAEFC30C8FD34388F02C9B3121859D1C25134A@eusaamb103.ericsson.se>
 <20140514.133716.106221573887805156.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"paul.gortmaker@windriver.com" <paul.gortmaker@windriver.com>,
	Erik Hugne <erik.hugne@ericsson.com>,
	"ying.xue@windriver.com" <ying.xue@windriver.com>,
	"maloy@donjonn.com" <maloy@donjonn.com>,
	"tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usevmg20.ericsson.net ([198.24.6.45]:56749 "EHLO
	usevmg20.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315AbaENRw4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 13:52:56 -0400
In-Reply-To: <20140514.133716.106221573887805156.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of David Miller
> Sent: May-14-14 1:37 PM
> To: Jon Maloy
> Cc: eric.dumazet@gmail.com; netdev@vger.kernel.org;
> paul.gortmaker@windriver.com; Erik Hugne; ying.xue@windriver.com;
> maloy@donjonn.com; tipc-discussion@lists.sourceforge.net
> Subject: Re: [PATCH net-next v2 2/8] tipc: compensate for double accounting
> in socket rcv buffer
> 
> From: Jon Maloy <jon.maloy@ericsson.com>
> Date: Wed, 14 May 2014 12:53:45 +0000
> 
> > Because TCP can throw away packet in such situations, and TIPC cannot.
> 
> Just want to state for the record that I consider any transport, even over
> directly connected ethernet, that cannot retransmit at the socket level and
> does not accomodate packet reordering, to be fundamentally flawed.

When I say link level, I am not talking about Ethernet. I am talking about
TIPC' own link layer that handles sequence ordering, retransmission,  
packet bundling (~NAGLE), flow control (not the same as the one we were
discussing) and   above all tight neighbor supervision and failover if one of
several parallel links fail. This can be carried over Ethernet, Infiniband, and
soon to come UDP.  We can detect neighbor loss within 50 ms in small
clusters, and either do failover or report the failure. Or both.

This worked flawlessly when we had 10 MB hubs with extreme loss rates,
and it still works fine. 

> 
> Even if you can absolutely prove that ethernet is %100 drop free and will
> never reorder your frames, some of those things can always happen in the
> system itself since memory is not infinite and your protocol is not the only
> consumer of kernel memory in the system.
> 
> You have to accomodate packet drops, at any level, and recover in some
> reasonable way from this.
> 
> So even with byte based flow control, TIPC I think will still have fundamental
> issues with data handling.

I once presented TIPC for you,  although it is a while ago.  Maybe you don't remember,
or I wasn't clear enough about this. All this is in place, and much more.

Regards
///jon

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the body
> of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
