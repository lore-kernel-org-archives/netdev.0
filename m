From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] bridge: vlan: allow to suppress
 local mac install for all vlans
Date: Tue, 25 Aug 2015 19:42:22 -0700 (PDT)
Message-ID: <20150825.194222.390859854071446877.davem@davemloft.net>
References: <1440549295-3979-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, bridge@lists.linux-foundation.org,
	nikolay@cumulusnetworks.com, netdev@vger.kernel.org,
	wkok@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1440549295-3979-1-git-send-email-razor@blackwall.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Tue, 25 Aug 2015 17:34:55 -0700

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> This patch adds a new knob that, when enabled, allows to suppress the
> installation of local fdb entries in newly created vlans. This could
> pose a big scalability issue if we have a large number of ports and a
> large number of vlans, e.g. in a 48 port device with 2000 vlans these
> entries easily go up to 96000.
> Note that packets for these macs are still received properly because they
> are added in vlan 0 as "own" macs and referenced when fdb lookup by vlan
> results in a miss.
> Also note that vlan membership of ingress port and the bridge device
> as egress are still being correctly enforced.
> 
> The default (0/off) is keeping the current behaviour.
> 
> Based on a patch by Wilson Kok (wkok@cumulusnetworks.com).
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
> v2: Triple checked the timezone

I'd rather we fix the essence of the scalability problem than add
more spaghetti code to the various bridge paths.

Can we make the fdb entries smaller?

Can we enhance how we store such local entries such that they live in
a compact datastructure?  Perhaps the FDB can consist of a very dense
lookup mechanism for local stuff sitting alongside the current table.
