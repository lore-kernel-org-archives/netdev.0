From: Jason Wang <jasowang@redhat.com>
Subject: Re: [rfc net-next v6 0/3] Multiqueue virtio-net
Date: Wed, 31 Oct 2012 18:33:15 +0800
Message-ID: <5090FE6B.4030001@redhat.com>
References: <1351591403-23065-1-git-send-email-jasowang@redhat.com>
	<509024F4.8080408@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, davem@davemloft.net
To: Rick Jones <rick.jones2@hp.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <509024F4.8080408@hp.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 10/31/2012 03:05 AM, Rick Jones wrote:
> On 10/30/2012 03:03 AM, Jason Wang wrote:
>> Hi all:
>>
>> This series is an update version of multiqueue virtio-net driver 
>> based on
>> Krishna Kumar's work to let virtio-net use multiple rx/tx queues to 
>> do the
>> packets reception and transmission. Please review and comments.
>>
>> Changes from v5:
>> - Align the implementation with the RFC spec update v4
>> - Switch the mode between single mode and multiqueue mode without reset
>> - Remove the 256 limitation of queues
>> - Use helpers to do the mapping between virtqueues and tx/rx queues
>> - Use commbined channels instead of separated rx/tx queus when do the 
>> queue
>> number configuartion
>> - Other coding style comments from Michael
>>
>> Reference:
>> - A protype implementation of qemu-kvm support could by found in
>> git://github.com/jasowang/qemu-kvm-mq.git
>> - V5 could be found at http://lwn.net/Articles/505388/
>> - V4 could be found at https://lkml.org/lkml/2012/6/25/120
>> - V2 could be found at http://lwn.net/Articles/467283/
>> - Michael virtio-spec: 
>> http://www.spinics.net/lists/netdev/msg209986.html
>>
>> Perf Numbers:
>>
>> - Pktgen test shows the receiving capability of the multiqueue 
>> virtio-net were
>>    dramatically improved.
>> - Netperf result shows latency were greately improved according to 
>> the test
>> result.
>
> I suppose it is technically correct to say that latency was improved, 
> but usually for aggregate request/response tests I tend to talk about 
> the aggregate transactions per second.

Sure.
>
> Do you have a hypothesis as to why the improvement dropped going to 20 
> concurrent sessions from 10?
>
> rick jones 

I'm investigating this issuse currently, but with no much ideas. The 
aggregate transactions per second scales pretty well even with 20 
cocurrent sessions when doing test between a local host and a local vm. 
Looks like some bottleneck were reached when doing testing over 10gb or 
vms as even if I increase the number of sessions, the result would not 
increase.
