From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 12/13] net/core: Add reading VF statistics
 through the PF netdevice
Date: Thu, 11 Jun 2015 20:37:10 +0300
Message-ID: <CAJ3xEMhpVnup6znPNPApWacOPzDUfXdo3Si-pKvrYQFTTrf=ZQ@mail.gmail.com>
References: <1433948378-17570-1-git-send-email-ogerlitz@mellanox.com>
	<1433948378-17570-13-git-send-email-ogerlitz@mellanox.com>
	<55785663.7030608@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:35800 "EHLO
	mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932737AbbFKRhL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 13:37:11 -0400
Received: by oiax69 with SMTP id x69so2236243oia.2
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2015 10:37:10 -0700 (PDT)
In-Reply-To: <55785663.7030608@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 10, 2015 at 6:23 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
> On 06/10/2015 07:59 AM, Or Gerlitz wrote:
>>
>> From: Eran Ben Elisha <eranbe@mellanox.com>
>>
>> Add ndo_get_vf_stats where the PF retrieves and fills the VFs traffic
>> statistics. Add rtnl_link_vf_stats64 for passing the VF statistics from
>> the PF to user-space.
>>
>> Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
>> Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
>> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
>> ---
>>   include/linux/netdevice.h    |    4 ++++
>>   include/uapi/linux/if_link.h |   11 +++++++++++
>>   net/core/rtnetlink.c         |   12 ++++++++++--
>>   3 files changed, 25 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index 6f5f71f..b1d3b88 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -1100,6 +1100,10 @@ struct net_device_ops {
>>                                                      struct ifla_vf_info
>> *ivf);
>>         int                     (*ndo_set_vf_link_state)(struct net_device
>> *dev,
>>                                                          int vf, int
>> link_state);
>> +       int                     (*ndo_get_vf_stats)(struct net_device
>> *dev,
>> +                                                   int vf,
>> +                                                   struct
>> rtnl_link_vf_stats64
>> +                                                   *vf_stats);
>>         int                     (*ndo_set_vf_port)(struct net_device *dev,
>>                                                    int vf,
>>                                                    struct nlattr *port[]);
>> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
>> index 1737b7a..9c25aeb 100644
>> --- a/include/uapi/linux/if_link.h
>> +++ b/include/uapi/linux/if_link.h
>> @@ -70,6 +70,16 @@ struct rtnl_link_stats64 {
>>         __u64   tx_compressed;
>>   };
>>
>> +/* VF statistics structure */
>> +struct rtnl_link_vf_stats64 {
>> +       __u64   rx_packets;             /* total packets received       */
>> +       __u64   tx_packets;             /* total packets transmitted    */
>> +       __u64   rx_bytes;               /* total bytes received         */
>> +       __u64   tx_bytes;               /* total bytes transmitted      */
>> +       __u64   broadcast;              /* broadcast packets received   */
>> +       __u64   multicast;              /* multicast packets received   */
>> +};
>
>
> Can we encode this in a nested netlink structure when its passed
> up to userspace? I have more stats I would like to export in the
> future such as dropped packets and if we put the structure in the UAPI
> we wont be able to easily extend this.

Yep, makes sense, I asked Eran to look on doing so.

> The structure could be moved into ./include/linux/if_link.h though.
