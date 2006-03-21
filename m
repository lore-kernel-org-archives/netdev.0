From: Sean Hefty <mshefty@ichips.intel.com>
Subject: Re: Re: [PATCH 4/6 v2] IB: address translation to
	map	IP toIB addresses (GIDs)
Date: Tue, 21 Mar 2006 13:08:35 -0800
Message-ID: <44206B53.8020701@ichips.intel.com>
References: <ORSMSX401FRaqbC8wSA0000000d@orsmsx401.amr.corp.intel.com>
	<adabqvza53f.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Roland Dreier <rdreier@cisco.com>
In-Reply-To: <adabqvza53f.fsf@cisco.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

Roland Dreier wrote:
>  > +struct workqueue_struct *rdma_wq;
>  > +EXPORT_SYMBOL(rdma_wq);
> 
> Sean, I don't think I saw an answer when I asked you this before.  Why
> is ib_addr exporting a workqueue?  Is there some sort of ordering
> constraint that is forcing other modules to go through the same
> workqueue for things?
> 
> This seems like a very fragile internal thing to be exposing, and I'm
> wondering if there's a better way to handle it.

I responded in a different thread, but here's what I wrote:

"This is simply an attempt to reduce/combine work queues used by the Infiniband 
code.  This keeps the threading a little simpler in the rdma_cm, since all 
callbacks are invoked using the same work queue.  (I'm also using this with the 
local SA/multicast code, but that's not ready for merging.)"

There's no specific ordering constraint that's required.  We're just ending up 
with several Infiniband modules creating their own work queues (ib_mad, ib_cm, 
ib_addr, rdma_cm, plus a couple more in modules under development), and this is 
an attempt to reduce that.  If having separate work queues would work better, 
there shouldn't be anything that prevents this.

- Sean
