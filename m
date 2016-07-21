From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] net: bridge: br_set_ageing_time takes a clock_t
Date: Thu, 21 Jul 2016 11:27:12 -0700
Message-ID: <CAM_iQpWCwe11Sc+w5Gi2QFBdwAX0nLUKOtnV-cND4uAAEwEX6w@mail.gmail.com>
References: <20160721164219.26723-1-vivien.didelot@savoirfairelinux.com>
 <CAM_iQpUzf6MiOqYNc-vX0A-mhZ_=URwVPoUD1TY7xC0amTZoww@mail.gmail.com> <874m7ilur0.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:34077 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884AbcGUS1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 14:27:33 -0400
In-Reply-To: <874m7ilur0.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 21, 2016 at 11:18 AM, Vivien Didelot
<vivien.didelot@savoirfairelinux.com> wrote:
> Hi Cong,
>
> Cong Wang <xiyou.wangcong@gmail.com> writes:
>
>> On Thu, Jul 21, 2016 at 9:42 AM, Vivien Didelot
>> <vivien.didelot@savoirfairelinux.com> wrote:
>>> Change the ageing_time type in br_set_ageing_time() from u32 to what it
>>> is expected to be, i.e. a clock_t.
>>
>> You also need to change struct switchdev_attr:
>>
>> struct switchdev_attr {
>>         struct net_device *orig_dev;
>>         enum switchdev_attr_id id;
>>         u32 flags;
>>         void *complete_priv;
>>         void (*complete)(struct net_device *dev, int err, void *priv);
>>         union {
>>                 struct netdev_phys_item_id ppid;        /* PORT_PARENT_ID */
>>                 u8 stp_state;                           /* PORT_STP_STATE */
>>                 unsigned long brport_flags;             /* PORT_BRIDGE_FLAGS */
>>                 u32 ageing_time;                        /* BRIDGE_AGEING_TIME */
>>                 bool vlan_filtering;                    /*
>> BRIDGE_VLAN_FILTERING */
>>         } u;
>> };
>
> Already changed in net/master as of eabfdda93477
> ("net: switchdev: change ageing_time type to clock_t").

Oh, your are right, sorry I was on net-next.
