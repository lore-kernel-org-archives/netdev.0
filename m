From: Holger Brunck <holger.brunck@keymile.com>
Subject: Re: [PATCH net-next] tipc: allow one link per bearer to neighboring
 nodes
Date: Mon, 11 May 2015 10:26:33 +0200
Message-ID: <555067B9.2040306@keymile.com>
References: <1415986399-23874-1-git-send-email-holger.brunck@keymile.com> <A2BAEFC30C8FD34388F02C9B3121859D1C3F0AC1@eusaamb103.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Ying Xue <ying.xue@windriver.com>,
	Erik Hugne <erik.hugne@ericsson.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jon Maloy <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-de.keymile.com ([195.8.104.250]:46745 "EHLO
	mail-de.keymile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752264AbbEKIcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 04:32:01 -0400
In-Reply-To: <A2BAEFC30C8FD34388F02C9B3121859D1C3F0AC1@eusaamb103.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi John,

On 05/06/2015 09:45 PM, Jon Maloy wrote:
> Hi Holger,
> I am trying to remember why you wanted to have this, especially since it
> didn't change anything in practice, because MAX_BEARERS is still 2.
> 

yes thats true for the mainline tree. We have on our side an additional bearer
for HDLC wich is not mainlined and therefore we have a different value for
MAX_BEARERS.

> This limit has to be changed, since we may want to have e.g. dual Ethernet
> links to some nodes and single UDP links to others (but never the same)
> 
> Despite this, I can find good reasons to not allow more than two links 
> between a node pair. (In particular, the failover mechanism becomes 
> much more complex)
>

on our side we already have two ethernet links between two nodes and in addition
a hdlc link between the nodes and therefore we get three links. The HDLC link is
not used for these two nodes, but the HDLC connection is a bus to other entities
in our TIPC network and due to the fact that TIPC is full meshed we get the HDLC
link automatically even if we don't need it for the two nodes in question.

But there is no possibility to break the full-meshed principle to say don't
create a link to a specific node via a specific bearer correct? Because in
general I agree with you two possible usable links between nodes should be enough.

Regards
Holger Brunck

> Regards
> ///jon
> 
> 
>> -----Original Message-----
>> From: Holger Brunck [mailto:holger.brunck@keymile.com]
>> Sent: Friday, November 14, 2014 12:33 PM
>> To: davem@davemloft.net
>> Cc: Jon Maloy; Holger Brunck; Ying Xue; Erik Hugne; netdev@vger.kernel.org
>> Subject: [PATCH net-next] tipc: allow one link per bearer to neighboring
>> nodes
>>
>> There is no reason to limit the amount of possible links to a neighboring node
>> to 2. If we have more then two bearers we can also establish more links.
>>
>> Signed-off-by: Holger Brunck <holger.brunck@keymile.com>
>> Reviewed-By: Jon Maloy <jon.maloy@ericsson.com>
>> cc: Ying Xue <ying.xue@windriver.com>
>> cc: Erik Hugne <erik.hugne@ericsson.com>
>> cc: netdev@vger.kernel.org
>> ---
>>  net/tipc/link.c | 5 +++--
>>  1 file changed, 3 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/tipc/link.c b/net/tipc/link.c index 1db162a..7cf8004 100644
>> --- a/net/tipc/link.c
>> +++ b/net/tipc/link.c
>> @@ -224,9 +224,10 @@ struct tipc_link *tipc_link_create(struct tipc_node
>> *n_ptr,
>>  	char addr_string[16];
>>  	u32 peer = n_ptr->addr;
>>
>> -	if (n_ptr->link_cnt >= 2) {
>> +	if (n_ptr->link_cnt >= MAX_BEARERS) {
>>  		tipc_addr_string_fill(addr_string, n_ptr->addr);
>> -		pr_err("Attempt to establish third link to %s\n", addr_string);
>> +		pr_err("Attempt to establish %uth link to %s. Max %u
>> allowed.\n",
>> +			n_ptr->link_cnt, addr_string, MAX_BEARERS);
>>  		return NULL;
>>  	}
>>
>> --
>> 2.1.2
> 
