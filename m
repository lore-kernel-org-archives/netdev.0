From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC 2/4] tuntap: Publish tuntap maximum number of queues as
 module_param
Date: Sun, 24 Aug 2014 13:14:21 +0200
Message-ID: <20140824111421.GC9561@redhat.com>
References: <1408369040-1216-1-git-send-email-pagupta@redhat.com>
 <1408369040-1216-3-git-send-email-pagupta@redhat.com>
 <20140820105817.GB1916@nanopsycho.orion>
 <20140820111724.GE17371@redhat.com>
 <53F575F8.7000208@redhat.com>
 <175719847.27217377.1408708342392.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>, Jiri Pirko <jiri@resnulli.us>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, dgibson@redhat.com, vfalico@gmail.com,
	edumazet@google.com, vyasevic@redhat.com, hkchu@google.com,
	wuzhy@linux.vnet.ibm.com, xemul@parallels.com, therbert@google.com,
	bhutchings@solarflare.com, xii@google.com,
	stephen@networkplumber.org
To: Pankaj Gupta <pagupta@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <175719847.27217377.1408708342392.JavaMail.zimbra@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 22, 2014 at 07:52:22AM -0400, Pankaj Gupta wrote:
> 
> > 
> > On 08/20/2014 07:17 PM, Michael S. Tsirkin wrote:
> > > On Wed, Aug 20, 2014 at 12:58:17PM +0200, Jiri Pirko wrote:
> > >> > Mon, Aug 18, 2014 at 03:37:18PM CEST, pagupta@redhat.com wrote:
> > >>> > > This patch publishes maximum number of tun/tap queues allocated as a
> > >>> > > read_only module parameter which a user space application like
> > >>> > > libvirt
> > >>> > > can make use of to limit maximum number of queues. Value of read_only
> > >>> > > module parameter can be writable only at module load time. If no
> > >>> > > value is set
> > >>> > > at module load time a default value 256 is used which is equal to
> > >>> > > maximum number
> > >>> > > of vCPUS allowed by KVM.
> > >>> > >
> > >>> > > Administrator can specify maximum number of queues only at the driver
> > >>> > > module load time.
> > >>> > >
> > >>> > >Signed-off-by: Pankaj Gupta <pagupta@redhat.com>
> > >>> > >---
> > >>> > > drivers/net/tun.c |   13 +++++++++++--
> > >>> > > 1 files changed, 11 insertions(+), 2 deletions(-)
> > >>> > >
> > >>> > >diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> > >>> > >index acaaf67..1f518e2 100644
> > >>> > >--- a/drivers/net/tun.c
> > >>> > >+++ b/drivers/net/tun.c
> > >>> > >@@ -119,6 +119,9 @@ struct tap_filter {
> > >>> > > 
> > >>> > > #define TUN_FLOW_EXPIRE (3 * HZ)
> > >>> > > 
> > >>> > >+static int max_tap_queues = MAX_TAP_QUEUES;
> > >>> > >+module_param(max_tap_queues, int, S_IRUGO);
> > >> > 
> > >> > Please do not introduce new module paramaters. Please other ways to
> > >> > interchange values with userspace.
> > > I suggested this initially, but thinking more about it, I agree.
> > >
> > > It's a global limit (necessary to limit memory utilization by
> > > userspace), but it should be possible to change it
> > > after module load.
> > 
> > How about pass this limit through ifr during TUNSETIFF, then
> > alloc_netdev_mq() can use this limit.
> 
> Any other ideas/comments from the experts. Or shall I re-repost other patches 
> in the series except this patch until we agree on one.
> 
> > 

It's kind of useless without a way for userspace to discover
how many queues it can create, no?
