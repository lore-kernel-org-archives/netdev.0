From: Julian Anastasov <ja@ssi.bg>
Subject: RE: PMTU issues due to TOS field manipulation (for DSCP)
Date: Thu, 11 Dec 2003 02:17:19 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0312110207290.1519-100000@u.domain.uli>
References: <7E713DB94F47914DB5AAB80DE8EEA87501539908@fmsmsx410.fm.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, <niv@us.ibm.com>, <ak@suse.de>,
        <ruddk@us.ibm.com>, <kuznet@ms2.inr.ac.ru>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Johnson, Chester F" <chester.f.johnson@intel.com>
In-Reply-To: <7E713DB94F47914DB5AAB80DE8EEA87501539908@fmsmsx410.fm.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Wed, 10 Dec 2003, Johnson, Chester F wrote:

> I'm trying to think through one potential issue with ignoring the TOS
> field. Would/should a route redirect have to match the same src-dst-tos
> hash?

	It will surely match as before, as long as you do not
change the sysctl var to ignore the TOS.

> 1. Assume the network uses DSCP to make routing decisions.
> 2. Assume the first hop routers are configured as passive and do not
> advertise routes to the supported subnets and presumes static routes
> configured on end hosts.
> 3. The Linux host has multiple network interfaces for route diversity.
>
> The preferred route may send the frame to the wrong router and then
> ignore the icmp route redirect. Or would it?

	That is why I prefer 3 states, we will be able to route by
TOS (it will not be ignored for routing and cache) but still to
ignore TOS for PMTUD. I think, we need one proc entry that will
alter 2 int variables: whether TOS is ignored for PMTU and another
for the routing TOS mask. As we see, if we ignore TOS and OIF
for PMTU, all possible paths (including different TOS and OIF
values) between SADDR and DADDR will have same PMTU and we can
not solve this problem, we have to update PMTU for all these
entries.

Regards

--
Julian Anastasov <ja@ssi.bg>
