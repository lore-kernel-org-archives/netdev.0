From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: [PATCH net-next] softirq: reduce latencies
Date: Fri, 4 Jan 2013 12:57:14 +0100
Message-ID: <CA+icZUW6ZXP_8=RUTHLFMzq1X6fBsuVGGufT1w0k8fXcOu=oFg@mail.gmail.com>
References: <CA+icZUVEvzyrPsQG1QWLnHxhtaewaWTOVzBpTnLqjKuHMjjFHg@mail.gmail.com>
	<1357219919.21409.24519.camel@edumazet-glaptop>
	<50E5DEEF.2080009@hp.com>
	<1357274510.21409.27807.camel@edumazet-glaptop>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=047d7b6777002c01d104d2752ef0
Cc: Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1357274510.21409.27807.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--047d7b6777002c01d104d2752ef0
Content-Type: text/plain; charset=UTF-8

On Fri, Jan 4, 2013 at 5:41 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2013-01-03 at 11:41 -0800, Rick Jones wrote:
>
>> In terms of netperf overhead, once you specify P99_LATENCY, you are
>> already in for the pound of cost but only getting the penny of output
>> (so to speak).  While it would clutter the output, one could go ahead
>> and ask for the other latency stats and it won't "cost" anything more:
>>
>> ... -- -k
>> RT_LATENCY,MIN_LATENCY,MAX_LATENCY,P50_LATENCY,P90_LATENCY,P99_LATENCY,MEAN_LATENCY,STDDEV_LATENCY
>>
>> Additional information about how the omni output selectors work can be
>> found at
>> http://www.netperf.org/svn/netperf2/trunk/doc/netperf.html#Omni-Output-Selection
>>
>> happy benchmarking,
>>
>> rick jones
>>
>> BTW - you will likely see some differences between RT_LATENCY, which is
>> calculated from the average transactions per second, and MEAN_LATENCY,
>> which is calculated from the histogram of individual latencies
>> maintained when any of the _LATENCY outputs other than RT_LATENCY is
>> requested.  Kudos to the folks at Google who did the extensions to the
>> then-existing histogram code to enable it to be used for more reasonably
>> accurate statistics.
>>
>
> Yeah ;)
>
> Here are the before/after_patch results, cpu 2 handling the NIC irqs :
>
>
> Before patch :
>
> # netperf -H 7.7.7.84 -t TCP_RR -T2,2 -- -k
> RT_LATENCY,MIN_LATENCY,MAX_LATENCY,P50_LATENCY,P90_LATENCY,P99_LATENCY,MEAN_LATENCY,STDDEV_LATENCY
> MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET
> to 7.7.7.84 () port 0 AF_INET : first burst 0 : cpu bind
> RT_LATENCY=550110.424
> MIN_LATENCY=146858
> MAX_LATENCY=997109
> P50_LATENCY=305000
> P90_LATENCY=550000
> P99_LATENCY=710000
> MEAN_LATENCY=376989.12
> STDDEV_LATENCY=184046.92
>
> After patch :
>
> # netperf -H 7.7.7.84 -t TCP_RR -T2,2 -- -k
> RT_LATENCY,MIN_LATENCY,MAX_LATENCY,P50_LATENCY,P90_LATENCY,P99_LATENCY,MEAN_LATENCY,STDDEV_LATENCY
> MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET
> to 7.7.7.84 () port 0 AF_INET : first burst 0 : cpu bind
> RT_LATENCY=40545.492
> MIN_LATENCY=9834
> MAX_LATENCY=78366
> P50_LATENCY=33583
> P90_LATENCY=59000
> P99_LATENCY=69000
> MEAN_LATENCY=38364.67
> STDDEV_LATENCY=12865.26
>

I also wanted to give some numbers.
But with localhost as default (no netserver running on a remote-host)
I am not sure if these numbers give any helpful feedback.
( I have not tested yet w/o your patch. )

- Sedat -

--047d7b6777002c01d104d2752ef0
Content-Type: text/plain; charset=US-ASCII; name="NETPERF_softirq-experimental.txt"
Content-Disposition: attachment; filename="NETPERF_softirq-experimental.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hbj9pzid0

IyBuZXRwZXJmIC1IIGxvY2FsaG9zdCAtdCBUQ1BfUlIgLVQyLDIgLS0gLWsgUlRfTEFURU5DWSxN
SU5fTEFURU5DWSxNQVhfTEFURU5DWSxQNTBfTEFURU5DWSxQOTBfTEFURU5DWSxQOTlfTEFURU5D
WSxNRUFOX0xBVEVOQ1ksU1REREVWX0xBVEVOQ1kKTUlHUkFURUQgVENQIFJFUVVFU1QvUkVTUE9O
U0UgVEVTVCBmcm9tIDAuMC4wLjAgKDAuMC4wLjApIHBvcnQgMCBBRl9JTkVUIHRvIGxvY2FsaG9z
dCAoMTI3LjAuMC4xKSBwb3J0IDAgQUZfSU5FVCA6IGRlbW8gOiBmaXJzdCBidXJzdCAwIDogY3B1
IGJpbmQKUlRfTEFURU5DWT0xMS40MDcKTUlOX0xBVEVOQ1k9MTAKTUFYX0xBVEVOQ1k9MTUyClA1
MF9MQVRFTkNZPTExClA5MF9MQVRFTkNZPTEyClA5OV9MQVRFTkNZPTEzCk1FQU5fTEFURU5DWT0x
MS4zMQpTVERERVZfTEFURU5DWT0wLjk1CgojIG5ldHBlcmYgLUggbG9jYWxob3N0IC10IFRDUF9S
UiAtVDIsMiAtLSAtayBSVF9MQVRFTkNZLE1JTl9MQVRFTkNZLE1BWF9MQVRFTkNZLFA1MF9MQVRF
TkNZLFA5MF9MQVRFTkNZLFA5OV9MQVRFTkNZLE1FQU5fTEFURU5DWSxTVERERVZfTEFURU5DWQpN
SUdSQVRFRCBUQ1AgUkVRVUVTVC9SRVNQT05TRSBURVNUIGZyb20gMC4wLjAuMCAoMC4wLjAuMCkg
cG9ydCAwIEFGX0lORVQgdG8gbG9jYWxob3N0ICgxMjcuMC4wLjEpIHBvcnQgMCBBRl9JTkVUIDog
ZGVtbyA6IGZpcnN0IGJ1cnN0IDAgOiBjcHUgYmluZApSVF9MQVRFTkNZPTExLjM2NApNSU5fTEFU
RU5DWT0xMApNQVhfTEFURU5DWT0xNTYKUDUwX0xBVEVOQ1k9MTEKUDkwX0xBVEVOQ1k9MTIKUDk5
X0xBVEVOQ1k9MTMKTUVBTl9MQVRFTkNZPTExLjI3ClNURERFVl9MQVRFTkNZPTEuMDYKCiMgbmV0
cGVyZiAtSCBsb2NhbGhvc3QgLXQgVENQX1JSIC1UMiwyIC0tIC1rIFJUX0xBVEVOQ1ksTUlOX0xB
VEVOQ1ksTUFYX0xBVEVOQ1ksUDUwX0xBVEVOQ1ksUDkwX0xBVEVOQ1ksUDk5X0xBVEVOQ1ksTUVB
Tl9MQVRFTkNZLFNURERFVl9MQVRFTkNZCk1JR1JBVEVEIFRDUCBSRVFVRVNUL1JFU1BPTlNFIFRF
U1QgZnJvbSAwLjAuMC4wICgwLjAuMC4wKSBwb3J0IDAgQUZfSU5FVCB0byBsb2NhbGhvc3QgKDEy
Ny4wLjAuMSkgcG9ydCAwIEFGX0lORVQgOiBkZW1vIDogZmlyc3QgYnVyc3QgMCA6IGNwdSBiaW5k
ClJUX0xBVEVOQ1k9MTEuNDA4Ck1JTl9MQVRFTkNZPTEwCk1BWF9MQVRFTkNZPTE1NgpQNTBfTEFU
RU5DWT0xMQpQOTBfTEFURU5DWT0xMgpQOTlfTEFURU5DWT0xMwpNRUFOX0xBVEVOQ1k9MTEuMzEK
U1REREVWX0xBVEVOQ1k9MS4wNwoKIyBuZXRwZXJmIC1IIGxvY2FsaG9zdCAtdCBUQ1BfUlIgLVQy
LDIgLS0gLWsgUlRfTEFURU5DWSxNSU5fTEFURU5DWSxNQVhfTEFURU5DWSxQNTBfTEFURU5DWSxQ
OTBfTEFURU5DWSxQOTlfTEFURU5DWSxNRUFOX0xBVEVOQ1ksU1REREVWX0xBVEVOQ1kKTUlHUkFU
RUQgVENQIFJFUVVFU1QvUkVTUE9OU0UgVEVTVCBmcm9tIDAuMC4wLjAgKDAuMC4wLjApIHBvcnQg
MCBBRl9JTkVUIHRvIGxvY2FsaG9zdCAoMTI3LjAuMC4xKSBwb3J0IDAgQUZfSU5FVCA6IGRlbW8g
OiBmaXJzdCBidXJzdCAwIDogY3B1IGJpbmQKUlRfTEFURU5DWT0xMS4zMTIKTUlOX0xBVEVOQ1k9
MTAKTUFYX0xBVEVOQ1k9MTUxClA1MF9MQVRFTkNZPTExClA5MF9MQVRFTkNZPTEyClA5OV9MQVRF
TkNZPTEzCk1FQU5fTEFURU5DWT0xMS4yMgpTVERERVZfTEFURU5DWT0wLjk0CgojIG5ldHBlcmYg
LUggbG9jYWxob3N0IC10IFRDUF9SUiAtVDIsMiAtLSAtayBSVF9MQVRFTkNZLE1JTl9MQVRFTkNZ
LE1BWF9MQVRFTkNZLFA1MF9MQVRFTkNZLFA5MF9MQVRFTkNZLFA5OV9MQVRFTkNZLE1FQU5fTEFU
RU5DWSxTVERERVZfTEFURU5DWQpNSUdSQVRFRCBUQ1AgUkVRVUVTVC9SRVNQT05TRSBURVNUIGZy
b20gMC4wLjAuMCAoMC4wLjAuMCkgcG9ydCAwIEFGX0lORVQgdG8gbG9jYWxob3N0ICgxMjcuMC4w
LjEpIHBvcnQgMCBBRl9JTkVUIDogZGVtbyA6IGZpcnN0IGJ1cnN0IDAgOiBjcHUgYmluZApSVF9M
QVRFTkNZPTExLjM0NQpNSU5fTEFURU5DWT0xMApNQVhfTEFURU5DWT0xNTkKUDUwX0xBVEVOQ1k9
MTEKUDkwX0xBVEVOQ1k9MTIKUDk5X0xBVEVOQ1k9MTMKTUVBTl9MQVRFTkNZPTExLjI1ClNURERF
Vl9MQVRFTkNZPTEuMDMKCgotZGlsZWtzIC8vIDA0LUphbi0yMDEzCgo=
--047d7b6777002c01d104d2752ef0--
