From: David Ahern <david.ahern@oracle.com>
Subject: Re: [PATCH] net/rds: fix unaligned memory access
Date: Thu, 30 Apr 2015 10:19:21 -0600
Message-ID: <55425609.8060107@oracle.com>
References: <1430404073-16879-1-git-send-email-david.ahern@oracle.com> <20150430.114403.2012017340124788492.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	shamir.rabinovitch@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:30504 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705AbbD3QT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 12:19:26 -0400
In-Reply-To: <20150430.114403.2012017340124788492.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/30/15 9:44 AM, David Miller wrote:
> From: David Ahern <david.ahern@oracle.com>
> Date: Thu, 30 Apr 2015 10:27:53 -0400
>
>> @@ -183,8 +183,17 @@ void rds_ib_cm_connect_complete(struct rds_connection *conn, struct rdma_cm_even
>>
>>   	/* If the peer gave us the last packet it saw, process this as if
>>   	 * we had received a regular ACK. */
>> -	if (dp && dp->dp_ack_seq)
>> -		rds_send_drop_acked(conn, be64_to_cpu(dp->dp_ack_seq), NULL);
>> +	if (dp) {
>> +		/* dp structure start is not guaranteed to be 8 bytes aligned
>> +		 * so on SPARC we get trap for nu-aligned access. we solve
>> +		 * this by using the macros for unaligned memory access
>> +		 */
>
> "nu-aligned" is misspelled, and Mentioning sparc specifically is completely
> inappropriate because this is not a sparc specific problem.
>

oops meant to take that out. Will fix and resubmit.
