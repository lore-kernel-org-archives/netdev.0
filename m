From: "Sean Hefty" <sean.hefty@intel.com>
Subject: RE: [ofa-general] InfiniBand/RDMA merge plans for 2.6.24
Date: Thu, 13 Sep 2007 11:20:38 -0700
Message-ID: <000401c7f632$c993e8e0$65cc180a@amr.corp.intel.com>
References: <adahclymos8.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
To: "'Roland Dreier'" <rdreier@cisco.com>, <general@lists.openfabrics.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <adahclymos8.fsf@cisco.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

> - My user_mad P_Key index support patch.  I'll test the ioctl to
>   change to the new mode and merge this I guess, since Hal and Sean
>   have tested this out.

I can give this patch a reviewed-by: too, and I will also try to review a couple
of the pending ipoib patches.

> - Sean's QoS changes.  These look fine at first glance, and I just
>   plan to understand the backwards compatibility story (ie how this
>   works with an old SM) and merge.  Anyone who objects let me know.

The new QoS fields fall into fields that are currently reserved, which should be
ignored by an older SM.  I've only tested this against openSM however.

> - Sean's IB CM MRA interface changes.  Don't know at this point.  It
>   seems OK but I'm not clear on what if any real-world improvement
>   this gives us.

This patch was generated in response to an Intel MPI issue.  We've seen MPI take
several minutes to respond to a connection request during the middle of large
application runs.  When this happens, the active side times out the connection.
In OFED, we added module parameters to adjust the rdma_cm connection timeout on
the active side, but I believe that sending an MRA from the passive side is a
better solution.

- Sean
