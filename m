From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [ofa-general] Re: locking requirements when calling dev_set_mtu()
Date: Wed, 2 Jul 2008 18:15:52 +0100
Message-ID: <20080702171550.GE17872@solarflare.com>
References: <20080702085409.GA13098@mtls03>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Roland Dreier <rdreier@cisco.com>,
	fubar@us.ibm.com, general-list <general@lists.openfabrics.org>
To: Eli Cohen <eli@dev.mellanox.co.il>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <20080702085409.GA13098@mtls03>
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

Eli Cohen wrote:
> Hi,
> 
> I have the need to change the MTU of IP over IB from the driver code
> and not from the shell. Looking for the right way to do it I came
> across the dev_set_mtu() which seems appropriate as it handles all
> notifications too. However, it is not clear to me whether I have to
> wrap the call to dev_set_mtu() with any locks. Specifically, I was
> referred to a mail thread that suggests that I have to use
> rtnl_lock()/rtnl_unlock():
> http://marc.info/?l=linux-netdev&m=121201324611292&w=2
[...]

Essentially any function that changes net device configuration requires
the caller to hold the RTNL lock.  This probably ought to be consistently
documented through kernel-doc and/or ASSERT_RTNL() though.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
