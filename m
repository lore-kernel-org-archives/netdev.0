From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH iproute2] ip: mroute: Add table output to show command
Date: Wed, 14 Jun 2017 18:44:36 +0300
Message-ID: <49928c50-98a3-03e7-09e2-93c2b79644f7@cumulusnetworks.com>
References: <1497442092-14252-1-git-send-email-sharpd@cumulusnetworks.com>
 <eab71694-2e6e-65f8-62df-b68e76a13cff@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: David Ahern <dsahern@gmail.com>,
        Donald Sharp <sharpd@cumulusnetworks.com>,
        netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f180.google.com ([209.85.128.180]:35034 "EHLO
        mail-wr0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752393AbdFNPoj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 11:44:39 -0400
Received: by mail-wr0-f180.google.com with SMTP id q97so5936817wrb.2
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 08:44:38 -0700 (PDT)
In-Reply-To: <eab71694-2e6e-65f8-62df-b68e76a13cff@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/06/17 18:42, David Ahern wrote:
> On 6/14/17 6:08 AM, Donald Sharp wrote:
>> diff --git a/ip/ipmroute.c b/ip/ipmroute.c
>> index 4d2d758..70f4c4f 100644
>> --- a/ip/ipmroute.c
>> +++ b/ip/ipmroute.c
>> @@ -189,6 +189,11 @@ int print_mroute(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
>>  		fprintf(fp, ", Age %4i.%.2i", (int)tv.tv_sec,
>>  			(int)tv.tv_usec/10000);
>>  	}
>> +
>> +	if (table && (table != RT_TABLE_MAIN || show_details > 0) && !filter.tb)
>> +		fprintf(fp, " Table: %s",
> 
> I suggest lowercase 'table' to be consistent with ip route output.

This is consistent with the mroute show command, all of its fields start
with upper case.

> 
>> +			rtnl_rttable_n2a(table, b1, sizeof(b1)));
>> +
>>  	fprintf(fp, "\n");
>>  	fflush(fp);
>>  	return 0;
>> -- 
