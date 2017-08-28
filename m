From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: fdb add and delete tracepoints
Date: Mon, 28 Aug 2017 08:03:47 -0700
Message-ID: <CAJieiUgLAG9b8HVUEaWX=kTY13oUPDJPih+U8k19GG02XUeaTQ@mail.gmail.com>
References: <1503869593-30165-1-git-send-email-roopa@cumulusnetworks.com>
	<592631a3-6a80-407a-f087-37f7f04417d2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org,
	"davem@davemloft.net" <davem@davemloft.net>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <592631a3-6a80-407a-f087-37f7f04417d2@gmail.com>
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

On Sun, Aug 27, 2017 at 7:11 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 08/27/2017 02:33 PM, Roopa Prabhu wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> Tracepoints to trace bridge forwarding database updates.
>
> Thanks for adding this!
>
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> ---
>>  include/trace/events/bridge.h | 98 +++++++++++++++++++++++++++++++++++++++++++
>>  net/bridge/br_fdb.c           |  7 ++++
>>  net/core/net-traces.c         |  6 +++
>>  3 files changed, 111 insertions(+)
>>  create mode 100644 include/trace/events/bridge.h
>>
>> diff --git a/include/trace/events/bridge.h b/include/trace/events/bridge.h
>> new file mode 100644
>> index 0000000..e2d52cf
>> --- /dev/null
>> +++ b/include/trace/events/bridge.h
>> @@ -0,0 +1,98 @@
>> +#undef TRACE_SYSTEM
>> +#define TRACE_SYSTEM bridge
>> +
>> +#if !defined(_TRACE_BRIDGE_H) || defined(TRACE_HEADER_MULTI_READ)
>> +#define _TRACE_BRIDGE_H
>> +
>> +#include <linux/netdevice.h>
>> +#include <linux/tracepoint.h>
>> +
>> +#include "../../../net/bridge/br_private.h"
>> +
>> +TRACE_EVENT(br_fdb_add,
>> +
>> +     TP_PROTO(struct ndmsg *ndm, struct net_device *dev,
>> +              const unsigned char *addr, u16 vid, u16 nlh_flags),
>> +
>> +     TP_ARGS(ndm, dev, addr, vid, nlh_flags),
>> +
>> +     TP_STRUCT__entry(
>> +             __field(u8, ndm_flags)
>> +             __string(dev, dev->name)
>> +             __array(unsigned char, addr, 6)
>
> Can you use ETH_ALEN instead of 6 here?
>
>> +             __field(u16, vid)
>> +             __field(u16, nlh_flags)
>> +     ),
>> +
>> +     TP_fast_assign(
>> +             __assign_str(dev, dev->name);
>> +             memcpy(__entry->addr, addr, 6);
>
> Likewise
>
>> +             __entry->vid = vid;
>> +             __entry->nlh_flags = nlh_flags;
>> +             __entry->ndm_flags = ndm->ndm_flags;
>> +     ),
>> +
>> +     TP_printk("dev %s addr %02x:%02x:%02x:%02x:%02x:%02x vid %u nlh_flags %x ndm_flags = %x",
>
> I wonder if we could make %pM work for TP_printk() as this would
> simplify the argument list a bitt. Can you use %04x for vid, nlh_flags
> and %02x for ndm_flags?


one thing here.., i think %u is better for vid. bridge driver debug
prints also use %u for vid.
