From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next] virtio-net: enable multiqueue by default
Date: Mon, 28 Nov 2016 08:38:34 -0800
Message-ID: <583C5D8A.2030307@gmail.com>
References: <1480048646-17536-1-git-send-email-jasowang@redhat.com>
	<20161125064201-mutt-send-email-mst@kernel.org>
	<20161128.112823.2263657283777032168.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nhorman@redhat.com, jeder@redhat.com, hannes@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, myllynen@redhat.com,
	maxime.coquelin@redhat.com
To: David Miller <davem@davemloft.net>, mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20161128.112823.2263657283777032168.davem@davemloft.net>
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

On 16-11-28 08:28 AM, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Fri, 25 Nov 2016 06:43:08 +0200
> 
>> On Fri, Nov 25, 2016 at 12:37:26PM +0800, Jason Wang wrote:
>>> We use single queue even if multiqueue is enabled and let admin to
>>> enable it through ethtool later. This is used to avoid possible
>>> regression (small packet TCP stream transmission). But looks like an
>>> overkill since:
>>>
>>> - single queue user can disable multiqueue when launching qemu
>>> - brings extra troubles for the management since it needs extra admin
>>>   tool in guest to enable multiqueue
>>> - multiqueue performs much better than single queue in most of the
>>>   cases
>>>
>>> So this patch enables multiqueue by default: if #queues is less than or
>>> equal to #vcpu, enable as much as queue pairs; if #queues is greater
>>> than #vcpu, enable #vcpu queue pairs.
>>>
>>> Cc: Hannes Frederic Sowa <hannes@redhat.com>
>>> Cc: Michael S. Tsirkin <mst@redhat.com>
>>> Cc: Neil Horman <nhorman@redhat.com>
>>> Cc: Jeremy Eder <jeder@redhat.com>
>>> Cc: Marko Myllynen <myllynen@redhat.com>
>>> Cc: Maxime Coquelin <maxime.coquelin@redhat.com>
>>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>>
>> OK at some level but all uses of num_online_cpus()
>> like this are racy versus hotplug.
>> I know we already have this bug but shouldn't we fix it
>> before we add more?
> 
> This is more being used like a heuristic in this scenerio, and in
> fact I would say one would keep the code this way even once proper
> hotplug handlers are installed to adjust the queued dynamically if
> there is a desired (which is also not necessarily the case).
> 
> I really don't think this change should be held on up on this issue.
> So can we please make some forward progress here?
> 
> Thanks.
> 

Also it might be worth noting all the other multiqueue capable
ethernet devices I checked use some variation of this heuristic.
Typically related to what other features are enables RSS, DCB, etc.
So it at least should be familiar to folks who do hotplug cpus on
bare metal boxes.

.John
