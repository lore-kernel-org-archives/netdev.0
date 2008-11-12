From: Roland Dreier <rdreier@cisco.com>
Subject: [ofa-general] Re: [PATCH 2.6.28] RDMA/cxgb3: deadlock in iw_cxgb3
	can cause hang when configuring interface.
Date: Wed, 12 Nov 2008 10:20:40 -0800
Message-ID: <adazlk4n6vb.fsf@cisco.com>
References: <20081106230642.28808.66765.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org, divy@chelsio.com,
	jeff@garzik.org, wenxiong@us.ibm.com
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20081106230642.28808.66765.stgit@dell3.ogc.int> (Steve Wise's
	message of "Thu, 06 Nov 2008 17:06:42 -0600")
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

Looks good, applied.

However, I think it's a little yucky to call ethtool ops without rtnl,
although it is of course perfectly safe in this case.  It might be nicer
to introduce a new cxgb3 <-> iw_cxgb3 interface that returns the
firmware version, which can also be used to implement the get_drvinfo
ethtool op as well.  That would let you avoid fw_vers_string_to_u64() as
well -- it is a little silly at the moment how cxgb3 converts to a
string and then iw_cxgb3 parses that string.

But that's all much lower priority than just fixing a deadlock.

 - R.
