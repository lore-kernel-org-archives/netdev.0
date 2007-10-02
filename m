From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: Tue, 02 Oct 2007 18:09:16 +0200
Message-ID: <47026D2C.9060606@hartkopp.net>
References: <20071002131006.31727.0@janus.isnogud.escape.de> <20071002131108.31727.2@janus.isnogud.escape.de> <20071002143855.GG7881@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Urs Thuermann <urs@isnogud.escape.de>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:36671 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752456AbXJBQJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 12:09:40 -0400
In-Reply-To: <20071002143855.GG7881@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnaldo Carvalho de Melo wrote:
> Em Tue, Oct 02, 2007 at 03:10:08PM +0200, Urs Thuermann escreveu:
>   
>> +
>> +/**
>> + * struct sockaddr_can - the sockaddr structure for CAN sockets
>> + * @can_family:  address family number AF_CAN.
>> + * @can_ifindex: CAN network interface index.
>> + * @can_addr:    transport protocol specific address, mostly CAN IDs.
>> + */
>> +struct sockaddr_can {
>> +	sa_family_t can_family;
>> +	int         can_ifindex;
>> +	union {
>> +		struct { canid_t rx_id, tx_id; } tp16;
>> +		struct { canid_t rx_id, tx_id; } tp20;
>> +		struct { canid_t rx_id, tx_id; } mcnet;
>> +		struct { canid_t rx_id, tx_id; } isotp;
>> +	} can_addr;
>>     
>
> Again being curious, what is the value of this union of all its members
> have the same definition? Backward source code compatibility?
>
>   

Yes. You're right here. It is a prerequisite for a CAN transportprotocol 
like the standardized ISO-TP i plan to submit here until december.

Indeed the union should be replaced by something like

struct sockaddr_can {
sa_family_t can_family;
int can_ifindex;
union {
struct { canid_t rx_id, tx_id; } tp;
} can_addr;
};


The union was the idea, if there is any other protocol for CAN that 
need's other adressing information. I personally do not know any 
protocol. Maybe CANOpen has different addressing requirements here. And 
in that case a new protocol could just could add things to the union to 
meet it's own needs.


>
> You have been thru many iterations already, sigh, I should have looked
> at this before :-\
>
>   

Yeah :-) I thought, you were just done last time.

Btw. Thanks for your review and your good feedback.

Regards,
Oliver

