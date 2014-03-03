From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH 6/7] bridge: Manage promisc mode when vlans are
 configured on top of a bridge
Date: Mon, 03 Mar 2014 07:12:32 -0500
Message-ID: <531471B0.1050705@redhat.com>
References: <1393427905-6811-1-git-send-email-vyasevic@redhat.com>	
	<1393427905-6811-7-git-send-email-vyasevic@redhat.com>	
	<530F2A4C.6020303@lab.ntt.co.jp> <530F3AD4.6080704@redhat.com>	
	<5310E4DE.1080003@redhat.com>
	<1393685845.1753.10.camel@localhost.localdomain>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	jhs@mojatatu.com, john.r.fastabend@intel.com, shemminger@vyatta.com
To: Toshiaki Makita <toshiaki.makita1@gmail.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1393685845.1753.10.camel@localhost.localdomain>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 03/01/2014 09:57 AM, Toshiaki Makita wrote:
> On Fri, 2014-02-28 at 14:34 -0500, Vlad Yasevich wrote:
>> On 02/27/2014 08:17 AM, Vlad Yasevich wrote:
>>> On 02/27/2014 07:06 AM, Toshiaki Makita wrote:
>>>> (2014/02/27 0:18), Vlad Yasevich wrote:
>>>>> If the user configures vlan interfaces on top of the bridge and the bridge
>>>>> doesn't have vlan filtering enabled, we have to place all the ports in
>>>>> promsic mode so that we can correctly receive tagged frames.
>>>>> When vlan filtering is enabled, the vlan configuration will be provided
>>>>> via filtering interface.
>>>>> When the vlan filtering is toggled, we also have mange promiscuity.
>>>>
>>>> If we disable vlan_filtering and no vlan interface is configured on the
>>>> bridge, we cannot forward any tagged traffic?
>>>
>>> We can't receive tagged traffic, so we turn promisc on.
>>>
>>>> If we want to forward frames from one port to another port (not from/to
>>>> bridge device), we have to add vlan interface or set promisc mode, right?
>>>>
>>>
>>> Hm..  Good point.  This isn't enough to address the scenario that Patch7
>>> tries to solve.  I'll need to think about that.  This is partially why
>>> I split functionality in Patch7 out.  It made things more difficult.
>>>
>>
>> I now understood what you were referring to above a bit better.
>> This patch solves just part of the problem.  The other part is what
>> happens when someone behind the bridge is using vlan tagging without
>> the bridge being aware of it and expects the bridge to forward such traffic.
>> So, if we ever want to disable promiscuous mode on the bridge ports, we
>> either need to depend on lan filtering being configured in the bridge
>> or have the ability to disable vlan filtering in the driver.
>>
>> Neither is really a good thing.  I'll need to think about this.
> 
> Yes, that is what I was worried about.
> As a bridge has no way to know which vid will be used in incoming
> frame's vlan tag, we maybe have to call vlan_vid_add() for all vids when
> we disable promiscuous on a port?  If we had an API to simply disable
> vlan filtering of a NIC, it could be better...

That's what I am looking at now.  Some nics appear to handle this better
then others.

-vlad

> 
> Thanks,
> Toshiaki Makita
> 
