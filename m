From: Roland Dreier <rdreier@cisco.com>
Subject: Re: Re: [PATCH 4/6 v2] IB: address translation to
	map	IP toIB addresses (GIDs)
Date: Tue, 21 Mar 2006 14:39:36 -0800
Message-ID: <ada3bhba0d3.fsf@cisco.com>
References: <ORSMSX401FRaqbC8wSA0000000d@orsmsx401.amr.corp.intel.com>
	<adabqvza53f.fsf@cisco.com> <44206B53.8020701@ichips.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Sean Hefty <mshefty@ichips.intel.com>
In-Reply-To: <44206B53.8020701@ichips.intel.com> (Sean Hefty's message of "Tue,
	21 Mar 2006 13:08:35 -0800")
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

    Sean> "This is simply an attempt to reduce/combine work queues
    Sean> used by the Infiniband code.  This keeps the threading a
    Sean> little simpler in the rdma_cm, since all callbacks are
    Sean> invoked using the same work queue.  (I'm also using this
    Sean> with the local SA/multicast code, but that's not ready for
    Sean> merging.)"

How does it keep the threading model simpler?  Is this an inter-module
dependency.

    Sean> There's no specific ordering constraint that's required.
    Sean> We're just ending up with several Infiniband modules
    Sean> creating their own work queues (ib_mad, ib_cm, ib_addr,
    Sean> rdma_cm, plus a couple more in modules under development),
    Sean> and this is an attempt to reduce that.  If having separate
    Sean> work queues would work better, there shouldn't be anything
    Sean> that prevents this.

It seems like it would be cleaner for each module to have its own
workqueue if it needs one.  There's also schedule_work(), although
that goes to a multi-threaded workqueue.  Michael Tsirkin has
suggested creating a system-wide single-threaded workqueue (ie
something like schedule_ordered_work()) for everyone that occasionally
needs a single-threaded workqueue.

 - R.
