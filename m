From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [BUG] ipv6 and TSO on GRE is broken
Date: Thu, 2 May 2013 01:00:54 -0700
Message-ID: <CALnjE+pvvHccEZZhH9ejCk4XGeTnWjupAFNfxvSAGdrOpHWhkg@mail.gmail.com>
References: <1367423622.11020.54.camel@edumazet-glaptop>
	<CALnjE+pPmsJx6zqcA7PnR3GX3HUrrtCbZyqj7nyEDBCv9_Tntw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	"Steinar H. Gunderson" <sesse@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog120.obsmtp.com ([74.125.149.140]:56845 "HELO
	na3sys009aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752159Ab3EBIA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 May 2013 04:00:56 -0400
Received: by mail-gh0-f198.google.com with SMTP id r13so482592ghr.5
        for <netdev@vger.kernel.org>; Thu, 02 May 2013 01:00:55 -0700 (PDT)
In-Reply-To: <CALnjE+pPmsJx6zqcA7PnR3GX3HUrrtCbZyqj7nyEDBCv9_Tntw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 2, 2013 at 12:02 AM, Pravin Shelar <pshelar@nicira.com> wrote:
> I forgot to add gre gso handler to inet6 offloads list.
>
> I will send out patch soon.
>
nevermind, I guess you were talking abt ipv6 over gre-ipv4 device, I
will check the code.

> Thanks,
> Pravin.
>
> On Wed, May 1, 2013 at 8:53 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> This was reported by Steinar.
>>
>> Sending this to netdev, as I wont have time to debug this in the near
>> future. (~ 3 days)
>>
>> 3.9 and latest net-next are broken for IPv6 on top of GRE tunnel
>>
>> GSO seems OK, but TSO not :
>>
>> lpq83:~# ethtool -K gre1 tso off gso on
>> lpq83:~# netperf -H 4444::555:0084
>> MIGRATED TCP STREAM TEST from ::0 (::) port 0 AF_INET6 to 4444::555:0084
>> () port 0 AF_INET6
>> Recv   Send    Send
>> Socket Socket  Message  Elapsed
>> Size   Size    Size     Time     Throughput
>> bytes  bytes   bytes    secs.    10^6bits/sec
>>
>>  87380  16384  16384    10.00    3789.10
>> lpq83:~# ethtool -K gre1 tso on
>> lpq83:~# netperf -H 4444::555:0084
>> MIGRATED TCP STREAM TEST from ::0 (::) port 0 AF_INET6 to 4444::555:0084
>> () port 0 AF_INET6
>> Recv   Send    Send
>> Socket Socket  Message  Elapsed
>> Size   Size    Size     Time     Throughput
>> bytes  bytes   bytes    secs.    10^6bits/sec
>>
>>  87380  16384  16384    10.00     321.27
>>
>>
>> No problem for IPv4
>>
>> Thanks
>>
>>
