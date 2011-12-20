From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: Re: [PATCH] sctp: Do not account for sizeof(struct sk_buff) in
 estimated rwnd
Date: Tue, 20 Dec 2011 13:00:48 +0800
Message-ID: <CAPgLHd-JL8cjMBSqO5Lc5nEt42zqj8qAn+qHaM35HTmnhOHg7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: vladislav.yasevich@hp.com, linux-sctp@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: tgraf@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:51013 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104Ab1LTFAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 00:00:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thomas,

> On Mon, Dec 19, 2011 at 03:11:40PM +0100, Thomas Graf wrote:
>> Trying to reproduce this I found that with the sk_buff overhead removed,
>> the performance would improve significantly unless socket buffer limits
>> are increased.
> I believe this is likely to be misunderstood. What I meant is that by
> removing the sk_buff overhead and while using default socket buffer limits
> the performance increases as shown below. If socket buffers are enlarged
> performance differences fade until there is no longer any difference.
>
> Sorry for poor wording.
>
>> The following numbers have been gathered using a patched iperf
>> supporting SCTP over a live 1 Gbit ethernet network. The -l option
>> was used to limit DATA chunk sizes. The numbers listed are based on
>> the average of 3 test runs each. Default values have been used for
>> sk_(r|w)mem.
>>
>> Chunk
>> Size    Unpatched     No Overhead
>> -------------------------------------
>>    4    15.2 Kbit [!]   12.2 Mbit [!]
>>    8    35.8 Kbit [!]   26.0 Mbit [!]
>>   16    95.5 Kbit [!]   54.4 Mbit [!]
>>   32   106.7 Mbit      102.3 Mbit
>>   64   189.2 Mbit      188.3 Mbit
>>  128   331.2 Mbit      334.8 Mbit
>>  256   537.7 Mbit      536.0 Mbit
>>  512   766.9 Mbit      766.6 Mbit
>> 1024   810.1 Mbit      808.6 Mbit

I saw you discussed this with Vlad in old mail:
    http://www.spinics.net/lists/linux-sctp/msg01365.html

You said you will update patch to include a per packet overhead,
but it does not include in this patch, what's wrong with in?
