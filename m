From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next PATCH v0 3/5] net: add fdb generic dump routine
Date: Mon, 26 Mar 2012 14:41:27 -0700
Message-ID: <4F70E287.80402@intel.com>
References: <CB94671B.49E3F%roprabhu@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, shemminger@vyatta.com, bhutchings@solarflare.com,
	davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, mst@redhat.com, chrisw@redhat.com,
	gregory.v.rose@intel.com, kvm@vger.kernel.org, sri@us.ibm.com,
	chealy@imsco-us.com
To: Roopa Prabhu <roprabhu@cisco.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <CB94671B.49E3F%roprabhu@cisco.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/25/2012 6:09 AM, Roopa Prabhu wrote:
> 
> 
> 
> On 3/18/12 11:52 PM, "John Fastabend" <john.r.fastabend@intel.com> wrote:
> 
>> This adds a generic dump routine drivers can call. It
>> should be sufficient to handle any bridging model that
>> uses the unicast address list. This should be most SR-IOV
>> enabled NICs.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>>

[...]

>> +/**
>> + * ndo_dflt_fdb_dump: default netdevice operation to dump an FDB table.
>> + * @nlh: netlink message header
>> + * @dev: netdevice
>> + *
>> + * Default netdevice operation to dump the existing unicast address list.
>> + * Returns zero on success.
>> + */
>> +int ndo_dflt_fdb_dump(struct sk_buff *skb,
>> +        struct netlink_callback *cb,
>> +        struct net_device *dev,
>> +        int idx)
>> +{
>> + struct netdev_hw_addr *ha;
>> + struct nlmsghdr *nlh;
>> + struct ndmsg *ndm;
>> + u32 pid, seq;
>> +
>> + pid = NETLINK_CB(cb->skb).pid;
>> + seq = cb->nlh->nlmsg_seq;
>> +
>> + netif_addr_lock_bh(dev);
>> + list_for_each_entry(ha, &dev->uc.list, list) {
>> +  if (idx < cb->args[0])
>> +   goto skip;
> 
> Any reason why its only uc ?. What about mc ?

Sure this might be useful to know for embedded devices
and likely more useful for the macvlan driver. I'll add
it in the next version.

Thanks,
John


