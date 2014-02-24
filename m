From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] loopback: sctp: add NETIF_F_SCTP_CSUM to device
 features
Date: Mon, 24 Feb 2014 11:31:47 +0100
Message-ID: <530B1F93.4010308@redhat.com>
References: <1393074113-9922-1-git-send-email-dborkman@redhat.com> <063D6719AE5E284EB5DD2968C1650D6D0F6C96DE@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20605 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751568AbaBXKby (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Feb 2014 05:31:54 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6C96DE@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/24/2014 11:17 AM, David Laight wrote:
> From: Daniel Borkmann
>> Drivers are allowed to set NETIF_F_SCTP_CSUM if they have
>> hardware crc32c checksumming support for the SCTP protocol.
>> Currently, NETIF_F_SCTP_CSUM flag is available in igb,
>> ixgbe, i40e/i40evf drivers and for vlan devices.
>>
>> If we don't have NETIF_F_SCTP_CSUM then crc32c is done
>> through CPU instructions, invoked from crypto layer, or
>> if not available as slow-path fallback in software.
>>
>> Currently, loopback device propagates checksum offloading
>> feature flags in dev->features, but is missing SCTP checksum
>> offloading. Therefore, account for NETIF_F_SCTP_CSUM as
>> well.
>>
>> Before patch:
>>
>> ./netperf_sctp -H 192.168.0.100 -t SCTP_STREAM_MANY
>> SCTP 1-TO-MANY STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.0.100 () port 0 AF_INET
>> Recv   Send    Send
>> Socket Socket  Message  Elapsed
>> Size   Size    Size     Time     Throughput
>> bytes  bytes   bytes    secs.    10^6bits/sec
>>
>> 4194304 4194304   4096    10.00    4683.50
>>
>> After patch:
> ...
>> 4194304 4194304   4096    10.00    15348.26
>
> That seems a much larger increase than you'd expect from removing
> a software CRC of the data chunks.
> Are you sure that some other difference in the data flows wasn't
> also triggered.

Yes, I run this multiple times with similar results and I double-checked
it with perf. Current code triggers crc32c implementation in software
fallback on my machine which is very expensive.

> I'm also not sure that 4096 is a representative message size for SCTP.

I used netperf default in this case.
