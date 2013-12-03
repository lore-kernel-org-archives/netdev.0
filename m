From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Wed, 4 Dec 2013 00:35:37 +0200
Message-ID: <CAJZOPZLHFpUFmj26cW541LauWy89=VO=iq99OMX_tf-aWAn-ag@mail.gmail.com>
References: <CAJZOPZL9LxB5HdqS=+gQW-MjvW2NsZOt3NPB7v1iOFoEB7SsMQ@mail.gmail.com>
	<1386105850.30495.38.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAJZOPZ+vnqLpdjS0TNdxDa4CNTzzfqp1=Ftjf86Fd5Lb+QdSzw@mail.gmail.com>
	<20131203.165034.1085515763685633822.davem@davemloft.net>
	<1386107714.30495.40.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAJZOPZL2dq2c=5tmx+2VHX9eD1gG=pqyiQcvCvCGT+_3SDFKkQ@mail.gmail.com>
	<20131203223053.GA26282@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Or Gerlitz <or.gerlitz@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Jerry Chu <hkchu@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:59489 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755117Ab3LCWfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 17:35:38 -0500
Received: by mail-pb0-f48.google.com with SMTP id md12so22054548pbc.35
        for <netdev@vger.kernel.org>; Tue, 03 Dec 2013 14:35:38 -0800 (PST)
In-Reply-To: <20131203223053.GA26282@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 4, 2013 at 12:30 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Wed, Dec 04, 2013 at 12:22:08AM +0200, Or Gerlitz wrote:
>> On Tue, Dec 3, 2013 at 11:55 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > On Tue, 2013-12-03 at 16:50 -0500, David Miller wrote:
>> >
>> >> At this point I would use drop monitor to figure out in what context
>> >> packets are being dropped on the floor.  There are scripts provided
>> >> with the perf tool to utilize it.
>> >
>> > Most easy way is to do :
>> >
>> > perf record -e skb:kfree_skb -a -g sleep 10
>>
>> some typo here? I tried the perf tool that comes with the net git
>>
>> ./perf record -e skb:kfree_skb -a -g sleep 10
>> invalid or unsupported event: 'skb:kfree_skb'
>> Run 'perf list' for a list of valid events
>>
>>  usage: perf record [<options>] [<command>]
>>     or: perf record [<options>] -- <command> [<options>]
>>
>>     -e, --event <event>   event selector. use 'perf list' to list
>> available events
>
> -g takes an optional argument. Reorder the arguments:
>
> perf record -e skb:kfree_skb -g -a sleep 10


Sorry, it doesn't help, I get the same error even with the oerf
kernel.org tree which has these events (no sign for skb's)


List of pre-defined events (to be used in -e):
  cpu-cycles OR cycles                               [Hardware event]
  instructions                                       [Hardware event]
  cache-references                                   [Hardware event]
  cache-misses                                       [Hardware event]
  branch-instructions OR branches                    [Hardware event]
  branch-misses                                      [Hardware event]
  bus-cycles                                         [Hardware event]
  stalled-cycles-frontend OR idle-cycles-frontend    [Hardware event]
  stalled-cycles-backend OR idle-cycles-backend      [Hardware event]
  ref-cycles                                         [Hardware event]

  cpu-clock                                          [Software event]
  task-clock                                         [Software event]
  page-faults OR faults                              [Software event]
  context-switches OR cs                             [Software event]
  cpu-migrations OR migrations                       [Software event]
  minor-faults                                       [Software event]
  major-faults                                       [Software event]
  alignment-faults                                   [Software event]
  emulation-faults                                   [Software event]

  L1-dcache-loads                                    [Hardware cache event]
  L1-dcache-load-misses                              [Hardware cache event]
  L1-dcache-stores                                   [Hardware cache event]
  L1-dcache-store-misses                             [Hardware cache event]
  L1-dcache-prefetches                               [Hardware cache event]
  L1-dcache-prefetch-misses                          [Hardware cache event]
  L1-icache-loads                                    [Hardware cache event]
  L1-icache-load-misses                              [Hardware cache event]
  L1-icache-prefetches                               [Hardware cache event]
  L1-icache-prefetch-misses                          [Hardware cache event]
  LLC-loads                                          [Hardware cache event]
  LLC-load-misses                                    [Hardware cache event]
  LLC-stores                                         [Hardware cache event]
  LLC-store-misses                                   [Hardware cache event]
  LLC-prefetches                                     [Hardware cache event]
  LLC-prefetch-misses                                [Hardware cache event]
  dTLB-loads                                         [Hardware cache event]
  dTLB-load-misses                                   [Hardware cache event]
  dTLB-stores                                        [Hardware cache event]
  dTLB-store-misses                                  [Hardware cache event]
  dTLB-prefetches                                    [Hardware cache event]
