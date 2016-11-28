From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: Netperf UDP issue with connected sockets
Date: Mon, 28 Nov 2016 10:40:32 -0800
Message-ID: <ee2ba554-80e3-aa10-9a95-c3a44e9aac2f@hpe.com>
References: <20140903165943.372b897b@redhat.com>
 <1409757426.26422.41.camel@edumazet-glaptop2.roam.corp.google.com>
 <20161116131609.4e5726b4@redhat.com>
 <7c4b43a4-74bf-1ee2-6f0d-17783b5d8fcb@hpe.com>
 <20161116234022.2bad179b@redhat.com>
 <1479342849.8455.233.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161117091638.5fab8494@redhat.com>
 <20730b37-d218-a1bb-d0fb-0f838e2a77b5@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3428.houston.hpe.com ([15.241.140.76]:25056 "EHLO
        g4t3428.houston.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751432AbcK1Skd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 13:40:33 -0500
In-Reply-To: <20730b37-d218-a1bb-d0fb-0f838e2a77b5@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/2016 10:33 AM, Rick Jones wrote:
> On 11/17/2016 12:16 AM, Jesper Dangaard Brouer wrote:
>>> time to try IP_MTU_DISCOVER ;)
>>
>> To Rick, maybe you can find a good solution or option with Eric's hint,
>> to send appropriate sized UDP packets with Don't Fragment (DF).
>
> Jesper -
>
> Top of trunk has a change adding an omni, test-specific -f option which
> will set IP_MTU_DISCOVER:IP_PMTUDISC_DO on the data socket.  Is that
> sufficient to your needs?

Usage examples:

raj@tardy:~/netperf2_trunk/src$ ./netperf -t UDP_STREAM -l 1 -H 
raj-folio.americas.hpqcorp.net -- -m 1472 -f
MIGRATED UDP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
raj-folio.americas.hpqcorp.net () port 0 AF_INET
Socket  Message  Elapsed      Messages
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

212992    1472   1.00        77495      0     912.35
212992           1.00        77495            912.35

[1]+  Done                    emacs nettest_omni.c
raj@tardy:~/netperf2_trunk/src$ ./netperf -t UDP_STREAM -l 1 -H 
raj-folio.americas.hpqcorp.net -- -m 14720 -f
MIGRATED UDP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
raj-folio.americas.hpqcorp.net () port 0 AF_INET
send_data: data send error: Message too long (errno 90)
netperf: send_omni: send_data failed: Message too long

happy benchmarking,

rick jones
