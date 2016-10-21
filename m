From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v2 2/2] reuseport, bpf: add test case for bpf_get_numa_node_id
Date: Fri, 21 Oct 2016 13:22:43 +0200
Message-ID: <5809FA83.10308@iogearbox.net>
References: <cover.1477043972.git.daniel@iogearbox.net> <a3bb5be5fdab7b8415adcad984442181196609a7.1477043973.git.daniel@iogearbox.net> <20161021110801.GA2140@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, alexei.starovoitov@gmail.com,
        edumazet@google.com, netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36108 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754148AbcJULWs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 07:22:48 -0400
In-Reply-To: <20161021110801.GA2140@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/21/2016 01:08 PM, Jiri Pirko wrote:
> Fri, Oct 21, 2016 at 12:46:34PM CEST, daniel@iogearbox.net wrote:
>> The test case is very similar to reuseport_bpf_cpu, only that here
>> we select socket members based on current numa node id.
>>
>>   # numactl -H
>>   available: 2 nodes (0-1)
>>   node 0 cpus: 0 1 2 3 4 5 12 13 14 15 16 17
>>   node 0 size: 128867 MB
>>   node 0 free: 120080 MB
>>   node 1 cpus: 6 7 8 9 10 11 18 19 20 21 22 23
>>   node 1 size: 96765 MB
>>   node 1 free: 87504 MB
>>   node distances:
>>   node   0   1
>>     0:  10  20
>>     1:  20  10
>>
>>   # ./reuseport_bpf_numa
>>   ---- IPv4 UDP ----
>>   send node 0, receive socket 0
>>   send node 1, receive socket 1
>>   send node 1, receive socket 1
>>   send node 0, receive socket 0
>>   ---- IPv6 UDP ----
>>   send node 0, receive socket 0
>>   send node 1, receive socket 1
>>   send node 1, receive socket 1
>>   send node 0, receive socket 0
>>   ---- IPv4 TCP ----
>>   send node 0, receive socket 0
>>   send node 1, receive socket 1
>>   send node 1, receive socket 1
>>   send node 0, receive socket 0
>>   ---- IPv6 TCP ----
>>   send node 0, receive socket 0
>>   send node 1, receive socket 1
>>   send node 1, receive socket 1
>>   send node 0, receive socket 0
>>   SUCCESS
>>
>> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
>> Acked-by: Alexei Starovoitov <ast@kernel.org>
>> ---
>> tools/testing/selftests/net/.gitignore           |   1 +
>> tools/testing/selftests/net/Makefile             |  11 +-
>> tools/testing/selftests/net/reuseport_bpf_numa.c | 255 +++++++++++++++++++++++
>> 3 files changed, 263 insertions(+), 4 deletions(-)
>> create mode 100644 tools/testing/selftests/net/reuseport_bpf_numa.c
>>
>> diff --git a/tools/testing/selftests/net/.gitignore b/tools/testing/selftests/net/.gitignore
>> index 0840684..afe109e 100644
>> --- a/tools/testing/selftests/net/.gitignore
>> +++ b/tools/testing/selftests/net/.gitignore
>> @@ -3,4 +3,5 @@ psock_fanout
>> psock_tpacket
>> reuseport_bpf
>> reuseport_bpf_cpu
>> +reuseport_bpf_numa
>> reuseport_dualstack
>> diff --git a/tools/testing/selftests/net/Makefile b/tools/testing/selftests/net/Makefile
>> index 0e53407..e24e4c8 100644
>> --- a/tools/testing/selftests/net/Makefile
>> +++ b/tools/testing/selftests/net/Makefile
>> @@ -1,14 +1,17 @@
>> # Makefile for net selftests
>>
>> -CFLAGS = -Wall -O2 -g
>> -
>> +CFLAGS =  -Wall -Wl,--no-as-needed -O2 -g
>
>             ^ why the extra space?
>
>> CFLAGS += -I../../../../usr/include/
>>
>> -NET_PROGS = socket psock_fanout psock_tpacket reuseport_bpf reuseport_bpf_cpu reuseport_dualstack
>> +NET_PROGS =  socket
>
>                ^ yet again. Sorry for nitpicking :)

No strong opinion; did this so it aligns with the next lines:

CFLAGS =  -Wall -Wl,--no-as-needed -O2 -g
CFLAGS += -I../../../../usr/include/

NET_PROGS =  socket
NET_PROGS += psock_fanout psock_tpacket
NET_PROGS += reuseport_bpf reuseport_bpf_cpu reuseport_bpf_numa
NET_PROGS += reuseport_dualstack
