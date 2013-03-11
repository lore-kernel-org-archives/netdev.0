From: Tim Gardner <tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH linux-next v2] SUNRPC: rpcrdma_register_default_external:
 Dynamically allocate ib_phys_buf
Date: Mon, 11 Mar 2013 12:51:44 -0600
Message-ID: <513E27C0.8050108@canonical.com>
References: <20130310202838.GL31448@fieldses.org> <1363023447-22453-1-git-send-email-tim.gardner@canonical.com> <20130311181450.GC30618@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Tom Tucker <tom-/Yg/VP3ZvrM@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shani Michaeli <shanim-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130311181450.GC30618-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/11/2013 12:14 PM, J. Bruce Fields wrote:
<snip>
>>
>> v2 - Move the array of 'struct ib_phys_buf' objects into struct rpcrdma_req
>> and pass this request down through rpcrdma_register_external() and
>> rpcrdma_register_default_external(). This is less overhead then using
>> kmalloc() and requires no extra error checking as the allocation burden is
>> shifted to the transport client.
> 
> Oh good--so that works, and the req is the right place to put this?  How
> are you testing this?
> 
> (Just want to make it clear: I'm *not* an expert on the rdma code, so my
> suggestion to put this in the rpcrdma_req was a suggestion for something
> to look into, not a claim that it's correct.)
> 

Just compile tested so far. Incidentally, I've been through the call stack:

call_transmit
 xprt_transmit
  xprt->ops->send_request(task)
   xprt_rdma_send_request
    rpcrdma_marshal_req
     rpcrdma_create_chunks
      rpcrdma_register_external
       rpcrdma_register_default_external

It appears that the context for kmalloc() should be fine unless there is
a spinlock held around call_transmit() (which seems unlikely).

rtg
-- 
Tim Gardner tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
