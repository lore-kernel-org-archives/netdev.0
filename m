From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [ofa-general] locking requirements when calling dev_set_mtu()
Date: Wed, 2 Jul 2008 11:54:09 +0300
Message-ID: <20080702085409.GA13098@mtls03>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roland Dreier <rdreier@cisco.com>,
	general-list <general@lists.openfabrics.org>
To: netdev <netdev@vger.kernel.org>, fubar@us.ibm.com
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
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

Hi,

I have the need to change the MTU of IP over IB from the driver code
and not from the shell. Looking for the right way to do it I came
across the dev_set_mtu() which seems appropriate as it handles all
notifications too. However, it is not clear to me whether I have to
wrap the call to dev_set_mtu() with any locks. Specifically, I was
referred to a mail thread that suggests that I have to use
rtnl_lock()/rtnl_unlock():
http://marc.info/?l=linux-netdev&m=121201324611292&w=2

With reference to the above URL, I would say that it is possible for
me to hit to the assertion ASSERT_RTNL() if I don't take rtnl_lock
prior to calling dev_set_mtu(). However I don't hit it, though I can't
count on that there will not be a case that any function registered
for notification would expect to see the lock acquired.

Can someone shed light on this?

Thanks,
Eli
