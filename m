From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v4 for-next 00/12] Add network namespace support in the
 RDMA-CM
Date: Thu, 28 May 2015 16:07:21 +0300
Message-ID: <55671309.6080303@mellanox.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
 <1432647280.28905.107.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1432647280.28905.107.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 26/05/2015 16:34, Doug Ledford wrote:
> On Sun, 2015-05-17 at 08:50 +0300, Haggai Eran wrote:
>> Thanks again everyone for the review comments. I've updated the patch set
>> accordingly. The main changes are in the first patch to use a read-write
>> semaphore instead of an SRCU, and with the reference counting of shared
>> ib_cm_ids.
>> Please let me know if I missed anything, or if there are other issues with
>> the series.
> 
> Hi Haggai,
> 
> I know you are probably busy reworking this right now on the basis of
> Jason's comments.  However, my biggest issue with this patch set right
> now is not technical (well, it is, but it's only partially technical).
Hi,

I'm sorry about the late reply. We had a holiday here, and then some
other tasks took precedence. I've only got back to working on this today.

> 
> This is a core feature more than anything else.  Namespaces for RDMA
> devices is not unique to IB or RoCE in any way.  Yet no thought has been
> given to how this will work universally across all of the RDMA capable
> devices (mainly I'm talking about iWARP here...
I don't agree. It is true we have are not planning to provide an iWarp
implementation for network namespaces, as we lack the capacity and the
expertise. However, I think that the changes we proposed to the rdma_cm
module will work with iWarp too. Perhaps with some of Jason's
suggestions it will be smoother, but even in the current design, I think
that if iWarp drivers can provide iw_cm with the network device on which
a request is received, then it should be simple to modify it for
namespace support without significant change to rdma_cm.

> I don't think this is an
> issue for usNIC as if you want namespace support there, you just start
> the user space app in a given namespace and you are probably 90% of the
> way there since the user space application gets its own device and so
> its own MAC/IP and all of the RDMA transfers are UDP, so the
> application's namespace should get inherited by all the rest, but Cisco
> would need to confirm that, hence why I say 90% of the way there, it
> needs confirmed).
> 
> So, while you are reworking things right now, you would ideally contact
> Steve Wise and/or Tatyana Nikolova and discuss the iWARP story on this.
> I know there won't be a lot of overlap between IB and iWARP, but last
> time you were asked you didn't even know if this setup could be extended
> to iWARP.
> 
> For this next statement, I know I'm directing this to you Haggai, but
> please don't take it that way.  I'm really using your patch set to make
> a broader point to everyone on the list.
> 
> When I look at patches for support for a given feature, one of the
> things I'm going to look at is whether or not that feature is specific
> to a given hardware type, or if it's a generic feature.  If it's a
> generic feature, then I'm going to want to know that the person
> submitting it has designed it well.  A pre-requisite of designing a
> generic feature well is that it considers all hardware types, not just
> your specific hardware type.  So when you come back with the next
> version of this patch set, please have an answer for how it should work
> on each hardware type even if you don't have implementation patches for
> each hardware type.

Well, because the RDMA subsystem supports a very diverse set of devices,
I think there are few people who know the details of all hardware types
well. If we are going to evolve the generic parts of the stack, we have
to cooperate. We have to rely on the knowledge of people on the mailing
list to say whether the feature is well designed for all hardware types,
or whether changes are warranted. In this specific case, the patches has
been on the list since February. I think it is enough time to allow
anyone who is interested in network namespace support to chime in.

Regards,
Haggai

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
