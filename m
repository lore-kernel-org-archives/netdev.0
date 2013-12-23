From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 2/2] netlink: specify netlink packet direction
 for nlmon
Date: Mon, 23 Dec 2013 01:06:24 +0100
Message-ID: <52B77E80.3010205@redhat.com>
References: <1387416579-3098-1-git-send-email-dborkman@redhat.com> <1387416579-3098-3-git-send-email-dborkman@redhat.com> <20131222.185628.593979257362137672.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, darkjames-ws@darkjames.pl
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32726 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755438Ab3LWAGa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Dec 2013 19:06:30 -0500
In-Reply-To: <20131222.185628.593979257362137672.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/23/2013 12:56 AM, David Miller wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Thu, 19 Dec 2013 02:29:39 +0100
>
>> @@ -29,6 +29,9 @@ struct sockaddr_ll {
>>   /* These ones are invisible by user level */
>>   #define PACKET_LOOPBACK		5		/* MC/BRD frame looped back */
>>   #define PACKET_FASTROUTE	6		/* Fastrouted frame	*/
>> +/* These ones are for nlmon devices */
>> +#define PACKET_USER		0		/* To user space */
>> +#define PACKET_KERNEL		1		/* To kernel space */
>
> I know it is tempting to do so, but please do not reuse values
> like this.

Hm, ok. As we only have 3 bits for all this, are you okay with
doing the following ...

#define PACKET_USER	6	/* To user space   */
#define PACKET_KERNEL	7	/* To kernel space */

PACKET_FASTROUTE isn't used anywhere in the tree, only defined
in this header file. Then, by doing this, we would still fit.

> THanks.
