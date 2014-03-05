From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net RESEND] vlan: don't allow to add VLAN on VLAN device
Date: Wed, 5 Mar 2014 09:31:14 +0800
Message-ID: <53167E62.4020601@huawei.com>
References: <530FF7BF.4030706@huawei.com> <53100677.2060705@intel.com> <1393978247.16256.27.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>,
	John Fastabend <john.r.fastabend@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393978247.16256.27.camel@deadeye.wl.decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2014/3/5 8:10, Ben Hutchings wrote:
> On Thu, 2014-02-27 at 19:45 -0800, John Fastabend wrote:
>> On 2/27/2014 6:43 PM, Ding Tianhong wrote:
>>> I run these steps:
>>>
>>> modprobe 8021q
>>> vconfig add eth2 20
>>> vconfig add eth2.20 20
>>> ifconfig eth2 xx.xx.xx.xx
>>>
>>> then the Call Trace happened:
>>>
>>
>> [...]
>>
>>> ========================================================================
>>>
>>> The reason is that if add vlan on vlan dev, the vlan dev will create vlan_info,
>>> then the notification will let the real dev to run dev_set_rx_mode() and hold
>>> netif_addr_lock, and then the real dev will call ndo_set_rx_mode(), if the real
>>> dev is vlan dev, the ndo_set_rx_mode() will hold netif_addr_lock again, so deadlock
>>> happened.
>>>
>>> Don't allow to add vlan on vlan dev to fix this problem.
>>>
>>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>>> ---
>>
>> I'm not sure we can just disable stacked vlans. There might be something
>> using them today and they have worked in the past. Lets try to find a
>> better fix.
> 
> I don't think there's any deadlock possible here.  We try to acquire the
> addr_list_lock for eth2.20, then the addr_list_lock for eth2.  We never
> try to acquire them in the opposite order.  The fix would involve
> telling lockdep about lock ordering between stacked net_devices (I have
> no idea how that's done).
> 
> Ben.
> 

Yep, it is a warning when the lockdep is open, I review the code again, and the deadlock would not happen,
just the same class of locks twice, so I think it is not a bugfix, just like a optimization.

Regards
Ding
