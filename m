From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: [ofa-general] Re: [PATCH 1/2] IPoIB: Fix unregister_netdev hang
Date: Wed, 19 Sep 2007 09:54:18 +0530
Message-ID: <OFA01CE194.AD0117AA-ON6525735B.0018086F-6525735B.001832DF@in.ibm.com>
References: <adak5qnjpr7.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net, general@lists.openfabrics.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <adak5qnjpr7.fsf@cisco.com>
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

Hi Roland,

> Please double check your tree.  I just very carefully looked at my
> trees, and the poll_more: label is added in commit 6b460a71 ("[NET]:
> Make NAPI polling independent of struct net_device objects.") which is
> only in the net-2.6.24 tree.  Of course Dave did not change the
> version information in the Makefile since he wouldn't want Linus to
> pick up any extra strange changes when he pulls, so a net-2.6.24 tree
> will look like 2.6.23-rc6 as you quoted.
>
> And the refcounting bug I fixed is only in net-2.6.24.

You are absolutely right. My wording was incorrect, I should have said
net-2.6.24 (which is *at* rev rc6).

>  > To be clear, netif_rx_schedule while we are still in the poll list
will not
>  > do any harm as it does nothing since NAPI_STATE_SCHED is still set
(cleared
>  > by netif_rx_complete which has not yet run). Effectively we
lost/delayed
>  > processing an interrupt, if I understood the code right.
>
> Right, we lose an interrupt, and since the CQ events are one-shot, we
> never get another one, and the interface is effectively dead.

Thanks,

- KK
