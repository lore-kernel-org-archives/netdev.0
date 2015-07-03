From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] net/bridge: Add missing in6_dev_put in
	br_validate_ipv6
Date: Fri, 3 Jul 2015 22:42:13 +0200
Message-ID: <20150703204213.GM16529@breakpoint.cc>
References: <1435946491-11148-1-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wei.liu2@citrix.com, ian.campbell@citrix.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, fw@strlen.de,
	linux-kernel@vger.kernel.org, Bernhard Thaler <bernhard.thaler@wvnet.at>,
	xen-devel@lists.xenproject.org, davem@davemloft.net,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Julien Grall <julien.grall@citrix.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1435946491-11148-1-git-send-email-julien.grall@citrix.com>
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

Julien Grall <julien.grall@citrix.com> wrote:
> The commit efb6de9b4ba0092b2c55f6a52d16294a8a698edd "netfilter: bridge:
> forward IPv6 fragmented packets" introduced a new function
> br_validate_ipv6 which take a reference on the inet6 device. Although,
> the reference is not released at the end.
> 
> This will result to the impossibility to destroy any netdevice using
> ipv6 and bridge.
> 
> Spotted while trying to destroy a Xen guest on the upstream Linux:
> "unregister_netdevice: waiting for vif1.0 to become free. Usage count = 1"

Ugh :-/

I think it makes more sense to use __in6_dev_get() instead which doesn't
take a reference.
