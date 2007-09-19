From: Roland Dreier <rdreier@cisco.com>
Subject: [ofa-general] Re: [PATCH 1/2] IPoIB: Fix unregister_netdev hang
Date: Tue, 18 Sep 2007 20:30:36 -0700
Message-ID: <adak5qnjpr7.fsf@cisco.com>
References: <OF402F2662.AACCDAF2-ON6525735B.00108C17-6525735B.0012AB74@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, general@lists.openfabrics.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <OF402F2662.AACCDAF2-ON6525735B.00108C17-6525735B.0012AB74@in.ibm.com>
	(Krishna Kumar2's message of "Wed, 19 Sep 2007 08:53:55 +0530")
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

 > > and I think that is only in Dave's net-2.6.24 tree now, right?
 > 
 > Nope, that was what I downloaded yesterday:
 > 
 > VERSION = 2
 > PATCHLEVEL = 6
 > SUBLEVEL = 23
 > EXTRAVERSION =-rc6
 > NAME = Pink Farting Weasel

Please double check your tree.  I just very carefully looked at my
trees, and the poll_more: label is added in commit 6b460a71 ("[NET]:
Make NAPI polling independent of struct net_device objects.") which is
only in the net-2.6.24 tree.  Of course Dave did not change the
version information in the Makefile since he wouldn't want Linus to
pick up any extra strange changes when he pulls, so a net-2.6.24 tree
will look like 2.6.23-rc6 as you quoted.

And the refcounting bug I fixed is only in net-2.6.24.

 > To be clear, netif_rx_schedule while we are still in the poll list will not
 > do any harm as it does nothing since NAPI_STATE_SCHED is still set (cleared
 > by netif_rx_complete which has not yet run). Effectively we lost/delayed
 > processing an interrupt, if I understood the code right.

Right, we lose an interrupt, and since the CQ events are one-shot, we
never get another one, and the interface is effectively dead.

 - R.
