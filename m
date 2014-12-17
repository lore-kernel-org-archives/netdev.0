From: rapier <rapier@psc.edu>
Subject: Re: [RFC PATCH net-next 0/5] tcp: TCP tracer
Date: Wed, 17 Dec 2014 15:45:49 -0500
Message-ID: <5491EB7D.7020909@psc.edu>
References: <CAADnVQJ+8mtB8LD=U7XbxOC2hxhDChxOELhZ3NEYeoTk1G3LYg@mail.gmail.com> <1418659395.9773.13.camel@edumazet-glaptop2.roam.corp.google.com> <D0B44739.74E8A%bmatheny@fb.com> <CAK6E8=fsKNcVBBewDw89cLLFuQb1a0parZ7hmvuRfherqjXTng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Laurent Chavey <chavey@google.com>, Martin Lau <kafai@fb.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Lawrence Brakmo <brakmo@fb.com>, Josef Bacik <jbacik@fb.com>,
	Kernel Team <Kernel-team@fb.com>
To: Yuchung Cheng <ycheng@google.com>, Blake Matheny <bmatheny@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:37236 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750999AbaLQUp6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2014 15:45:58 -0500
In-Reply-To: <CAK6E8=fsKNcVBBewDw89cLLFuQb1a0parZ7hmvuRfherqjXTng@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 12/15/14 2:56 PM, Yuchung Cheng wrote:
> On Mon, Dec 15, 2014 at 8:08 AM, Blake Matheny <bmatheny@fb.com> wrote:
>>
>> We have an additional set of patches for web10g that builds on these
>> tracepoints. It can be made to work either way, but I agree the idea of
>> something like a sockopt would be really nice.
>
> I'd like to compare these patches  with tools that parse pcap files to
> generate per-flow counters to collect RTTs, #dupacks, etc. What
> additional values or insights do they provide to improve/debug TCP
> performance? maybe an example?

So this is our use scenario:

If the stack were instrumented on a per flow basis we can gather metrics 
proactively. This data can likely be processed in a near real time basis 
to at least get some general idea about the health of the flow (dupack, 
cong events, spurious rto, etc). It's possible we can use this data to 
provisionally flag flows during the lifespan of the transfer. If we 
store the collected metrics NOC engineers can access this to make a 
final determination about performance. They may then start the 
resolution process immediately using data collected in situ. With the 
web10g data we do collect stack data but we are also collecting 
information about the path and the interaction between the application 
and the stack.

This scenario is particularly appealing in the realm of big data 
science. We're currently working with datasets that are hundreds of TBs 
in size and will soon be dealing with multiple PBs as a matter of 
course. In many cases we're aware of the path characteristics in advance 
via SDN so we can apply the macroscopic model and see when we're 
dropping below thresholds for that path. Since we're doing most of 
transfers between loosely federated sets of distantly located transfer 
nodes we don't generally have access to the far end of the connection 
which might be the right place to collect the pcap data.

> IMO these stats provide a general pictures of how TCP works of a
> specific network, but not enough to really nail specific bugs in TCP
> protocol or implementation. Then SNMP stats or sampling with pcap
> traces with offline analysis can achieve the same purpose.

I'd agree with that but in the scenario we are most interested in 
protocol/implementation issues are secondary concerns. They are 
important but we've mostly be focused on what we can do to make the 
scientific workflow easier when dealing with the transfer of large data 
sets.
