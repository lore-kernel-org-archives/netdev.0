From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v2 01/11] RDMA/CMA: Mark IPv4 addresses correctly when
 the listener is IPv6
Date: Tue, 21 Apr 2015 13:15:11 +0300
Message-ID: <5536232F.3050707@mellanox.com>
References: <1429520622-10303-1-git-send-email-haggaie@mellanox.com>
 <1429520622-10303-2-git-send-email-haggaie@mellanox.com>
 <20150420164140.GC7676@obsidianresearch.com>
 <CAJ3xEMgKFdr68Qt0vNCaf1p4YjPK2KUSn2FdtQVP0SZQ+Y7atg@mail.gmail.com>
 <20150420200111.GA32449@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"Shachar Raindel" <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"Or Gerlitz" <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150420200111.GA32449-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 20/04/2015 23:01, Jason Gunthorpe wrote:
> On Mon, Apr 20, 2015 at 09:38:02PM +0300, Or Gerlitz wrote:
>> On Mon, Apr 20, 2015 at 7:41 PM, Jason Gunthorpe
>> <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org> wrote:
>>> On Mon, Apr 20, 2015 at 12:03:32PM +0300, Haggai Eran wrote:
>>>> From: Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>>>>
>>>> When accepting a new connection with the listener being IPv6, the
>>>> family of the new connection is set as IPv6. This causes cma_zero_addr
>>>> function to return true on an non-zero address. As a result, the wrong
>>>> code path is taken. This causes the connection request to be rejected,
>>>> as the RDMA-CM code looks for the wrong type of device.
>>>
>>> This description doesn't really make sense as to what the problem is.
> 
>> Jason, could you take a look @ this thread
>> http://marc.info/?t=141589395000004&r=1&w=2 where the authors
>> addressed some comments from Sean and he eventually Acked the patch?
> 
> Please actually read my comments:
> 
>  If listen_id->route.addr.src_addr.ss_family != AF_INET then it is
>  invalid to cast to sockaddr_in.

That's correct. We didn't address it because it was part of the existing
code. Anyway, in a later patch in this series we move this code from the
CMA to the CM module. Then we get the port number from the service ID
instead of from the listener ID, since the listener ID's port isn't
available.

> 
> Sean asked basically the same thing, and his question was ignored too.
> 
> This should take care of it, testing, and figuring the fixes tag is
> left as an exercise to the reader..
> 

Fixes: e51060f08a61 ("IB: IP address based RDMA connection manager")
Tested-by: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Haggai
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
