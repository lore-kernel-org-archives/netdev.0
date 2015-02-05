From: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Subject: Re: [PATCH net-next v2] hyper-v: allow access to vmbus
 from userspace driver
Date: Thu, 5 Feb 2015 08:50:18 -0800
Message-ID: <20150205085018.06e8a691@urahara>
References: <20150204152029.65f02d64@urahara>
 <87egq4r5ao.fsf@vitty.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dev-VfR2kkLFssw@public.gmane.org, devel-tBiZLqfeLfOHmIFyCCdPziST3g8Odh+X@public.gmane.org,
 Haiyang Zhang <haiyangz-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>, KY Srinivasan <kys-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Vitaly Kuznetsov <vkuznets-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-VfR2kkLFssw@public.gmane.org>
In-Reply-To: <87egq4r5ao.fsf-hpI3/L/TUU23oHxwIazZmlaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <http://dpdk.org/ml/options/dev>,
 <mailto:dev-request-VfR2kkLFssw@public.gmane.org?subject=unsubscribe>
List-Archive: <http://dpdk.org/ml/archives/dev/>
List-Post: <mailto:dev-VfR2kkLFssw@public.gmane.org>
List-Help: <mailto:dev-request-VfR2kkLFssw@public.gmane.org?subject=help>
List-Subscribe: <http://dpdk.org/ml/listinfo/dev>,
 <mailto:dev-request-VfR2kkLFssw@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-VfR2kkLFssw@public.gmane.org
Sender: "dev" <dev-bounces-VfR2kkLFssw@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Thu, 05 Feb 2015 12:01:03 +0100
Vitaly Kuznetsov <vkuznets-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:

> Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org> writes:
> 
> > This is enables the hyper-v driver for DPDK <dev-VfR2kkLFssw@public.gmane.org>.
> > The hv_uio driver needs to access the shared vmbus monitor
> > pages.
> 
> Why can't we just make vmbus_connection struct public?
> 
> >
> > I would also like to put hv_uio in upstream kernel like other
> > uio drivers, but need to get API accepted with DPDK first.
> >
> > Signed-off-by: Stas Egorov <segorov-nYU0QVwCCFFWk0Htik3J/w@public.gmane.org>
> > Signed-off-by: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
> >
> > ---
> > v2 - simplify and rename to vmbus_get_monitor_pages
> >
> >  drivers/hv/connection.c |   20 +++++++++++++++++---
> >  include/linux/hyperv.h  |    3 +++
> >  2 files changed, 20 insertions(+), 3 deletions(-)
> >
> > --- a/drivers/hv/connection.c	2015-02-03 10:58:51.751752450 -0800
> > +++ b/drivers/hv/connection.c	2015-02-04 14:59:51.636194383 -0800
> > @@ -64,6 +64,15 @@ static __u32 vmbus_get_next_version(__u3
> >  	}
> >  }
> >
> > +void vmbus_get_monitor_pages(unsigned long *int_page,
> > +			     unsigned long monitor_pages[2])
> > +{
> 
> Too weird to be a public interface in my opinion.
> 
> > +	*int_page = (unsigned long)vmbus_connection.int_page;
> > +	monitor_pages[0] = (unsigned long)vmbus_connection.monitor_pages[0];
> > +	monitor_pages[1] = (unsigned long)vmbus_connection.monitor_pages[1];
> > +}
> > +EXPORT_SYMBOL_GPL(vmbus_get_monitor_pages);
> > +
> >  static int vmbus_negotiate_version(struct vmbus_channel_msginfo *msginfo,
> >  					__u32 version)
> >  {
> > @@ -347,10 +356,7 @@ static void process_chn_event(u32 relid)
> >  			else
> >  				bytes_to_read = 0;
> >  		} while (read_state && (bytes_to_read != 0));
> > -	} else {
> > -		pr_err("no channel callback for relid - %u\n", relid);
> >  	}
> > -
> >  }
> 
> This change wasn't mentioned in your commit msg.

Was in earlier commit. Need to prevent driver from logging error
when device is not claimed directly by existing kernel devices.
