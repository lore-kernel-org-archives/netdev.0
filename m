From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC 2/4] tuntap: Publish tuntap maximum number of queues as
 module_param
Date: Wed, 20 Aug 2014 13:46:20 +0200
Message-ID: <20140820114620.GC1916@nanopsycho.orion>
References: <1408369040-1216-1-git-send-email-pagupta@redhat.com>
 <1408369040-1216-3-git-send-email-pagupta@redhat.com>
 <20140820105817.GB1916@nanopsycho.orion>
 <20140820111724.GE17371@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pankaj Gupta <pagupta@redhat.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net, jasowang@redhat.com,
	dgibson@redhat.com, vfalico@gmail.com, edumazet@google.com,
	vyasevic@redhat.com, hkchu@google.com, wuzhy@linux.vnet.ibm.com,
	xemul@parallels.com, therbert@google.com,
	bhutchings@solarflare.com, xii@google.com,
	stephen@networkplumber.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140820111724.GE17371@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wed, Aug 20, 2014 at 01:17:24PM CEST, mst@redhat.com wrote:
>On Wed, Aug 20, 2014 at 12:58:17PM +0200, Jiri Pirko wrote:
>> Mon, Aug 18, 2014 at 03:37:18PM CEST, pagupta@redhat.com wrote:
>> > This patch publishes maximum number of tun/tap queues allocated as a
>> > read_only module parameter which a user space application like libvirt
>> > can make use of to limit maximum number of queues. Value of read_only
>> > module parameter can be writable only at module load time. If no value is set
>> > at module load time a default value 256 is used which is equal to maximum number
>> > of vCPUS allowed by KVM.
>> >
>> > Administrator can specify maximum number of queues only at the driver
>> > module load time.
>> >
>> >Signed-off-by: Pankaj Gupta <pagupta@redhat.com>
>> >---
>> > drivers/net/tun.c |   13 +++++++++++--
>> > 1 files changed, 11 insertions(+), 2 deletions(-)
>> >
>> >diff --git a/drivers/net/tun.c b/drivers/net/tun.c
>> >index acaaf67..1f518e2 100644
>> >--- a/drivers/net/tun.c
>> >+++ b/drivers/net/tun.c
>> >@@ -119,6 +119,9 @@ struct tap_filter {
>> > 
>> > #define TUN_FLOW_EXPIRE (3 * HZ)
>> > 
>> >+static int max_tap_queues = MAX_TAP_QUEUES;
>> >+module_param(max_tap_queues, int, S_IRUGO);
>> 
>> Please do not introduce new module paramaters. Please other ways to
>> interchange values with userspace.
>
>I suggested this initially, but thinking more about it, I agree.
>
>It's a global limit (necessary to limit memory utilization by
>userspace), but it should be possible to change it
>after module load.
>
>Additionally, userspace that has the FD should be able to
>retrieve the value without guessing that the FD is
>for the tun device (and not e.g. macvtap).
>To retrieve the value, an ioctl is probably the
>cleanest approach.
>
>To set it, how about a sysctl? I think the limit can also apply to
>all devices, not just tun.

Or netlink?

>
>-- 
>MST
