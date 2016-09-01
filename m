From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: [PATCH] softirq: let ksoftirqd do its job
Date: Thu, 1 Sep 2016 14:05:53 +0200
Message-ID: <251f077b-3d46-415d-c5f3-c3dea73a3c88@redhat.com>
References: <4f1c4b38528762619fff1fa963de8971006c1234.1472460085.git.pabeni@redhat.com>
 <20160831100854.23dad2d8@redhat.com>
 <1472650472.14381.317.camel@edumazet-glaptop3.roam.corp.google.com>
 <1472650688.32433.115.camel@redhat.com>
 <1472652643.14381.320.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160831164216.2901190c@redhat.com>
 <1472661956.14381.335.camel@edumazet-glaptop3.roam.corp.google.com>
 <1472665349.14381.356.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160831214043.2f44cf08@redhat.com>
 <1472676150.14381.363.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <peterz@infradead.org>,
        David Miller <davem@davemloft.net>,
        Rik van Riel <riel@redhat.com>,
        Paolo Abeni <pabeni@redhat.com>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <jbrouer@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472676150.14381.363.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 31.08.2016 22:42, Eric Dumazet wrote:
> On Wed, 2016-08-31 at 21:40 +0200, Jesper Dangaard Brouer wrote:
> 
>> I can confirm the improvement of approx 900Kpps (no wonder people have
>> been complaining about DoS against UDP/DNS servers).
>>
>> BUT during my extensive testing, of this patch, I also think that we
>> have not gotten to the bottom of this.  I was expecting to see a higher
>> (collective) PPS number as I add more UDP servers, but I don't.
>>
>> Running many UDP netperf's with command:
>>  super_netperf 4 -H 198.18.50.3 -l 120 -t UDP_STREAM -T 0,0 -- -m 1472 -n -N
> 
> Are you sure sender can send fast enough ?
> 
>>
>> With 'top' I can see ksoftirq are still getting a higher %CPU time:
>>
>>     PID   %CPU     TIME+  COMMAND
>>      3   36.5   2:28.98  ksoftirqd/0
>>  10724    9.6   0:01.05  netserver
>>  10722    9.3   0:01.05  netserver
>>  10723    9.3   0:01.05  netserver
>>  10725    9.3   0:01.05  netserver
> 
> Looks much better on my machine, with "udprcv -n 4" (using 4 threads,
> and 4 sockets using SO_REUSEPORT)

Would it make sense to include used socket backlog in udp socket lookup
compute_score calculation? Just want to throw out the idea, I actually
could imagine to also cause bad side effects.
