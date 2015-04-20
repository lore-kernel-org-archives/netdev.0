From: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2 01/11] RDMA/CMA: Mark IPv4 addresses correctly when the
 listener is IPv6
Date: Mon, 20 Apr 2015 21:38:02 +0300
Message-ID: <CAJ3xEMgKFdr68Qt0vNCaf1p4YjPK2KUSn2FdtQVP0SZQ+Y7atg@mail.gmail.com>
References: <1429520622-10303-1-git-send-email-haggaie@mellanox.com>
	<1429520622-10303-2-git-send-email-haggaie@mellanox.com>
	<20150420164140.GC7676@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150420164140.GC7676-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 20, 2015 at 7:41 PM, Jason Gunthorpe
<jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org> wrote:
> On Mon, Apr 20, 2015 at 12:03:32PM +0300, Haggai Eran wrote:
>> From: Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>>
>> When accepting a new connection with the listener being IPv6, the
>> family of the new connection is set as IPv6. This causes cma_zero_addr
>> function to return true on an non-zero address. As a result, the wrong
>> code path is taken. This causes the connection request to be rejected,
>> as the RDMA-CM code looks for the wrong type of device.
>
> This description doesn't really make sense as to what the problem is.
>
>> @@ -866,12 +866,12 @@ static void cma_save_ip4_info(struct rdma_cm_id *id, struct rdma_cm_id *listen_i
>>
>>       listen4 = (struct sockaddr_in *) &listen_id->route.addr.src_addr;
>>       ip4 = (struct sockaddr_in *) &id->route.addr.src_addr;
>> -     ip4->sin_family = listen4->sin_family;
>> +     ip4->sin_family = AF_INET;
>
> If listen_id->route.addr.src_addr.ss_family != AF_INET then it is
> invalid to cast to sockaddr_in.
>
> So listen4->sin_family MUST be AF_INET or this function MUST NOT be
> called.
>
> Forcing to AF_INET cannot be correct here.

Jason, could you take a look @ this thread
http://marc.info/?t=141589395000004&r=1&w=2 where the authors
addressed some comments from Sean and he eventually Acked the patch?

> What does this patch have to do with this series?

I believe it's either a pre-patch to address some assumption or
something they stepped on while testing

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
