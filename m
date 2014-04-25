From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH V2] sctp: reset flowi4_oif parameter on route lookup
Date: Fri, 25 Apr 2014 06:38:19 -0700
Message-ID: <20140425133819.GA26979@kroah.com>
References: <1398416141-18916-1-git-send-email-xufeng.zhang@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com, davem@davemloft.net,
	ja@ssi.bg, linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: Xufeng Zhang <xufeng.zhang@windriver.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1398416141-18916-1-git-send-email-xufeng.zhang@windriver.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 25, 2014 at 04:55:41PM +0800, Xufeng Zhang wrote:
> commit 813b3b5db83 (ipv4: Use caller's on-stack flowi as-is
> in output route lookups.) introduces another regression which
> is very similar to the problem of commit e6b45241c (ipv4: reset
> flowi parameters on route connect) wants to fix:
> Before we call ip_route_output_key() in sctp_v4_get_dst() to
> get a dst that matches a bind address as the source address,
> we have already called this function previously and the flowi
> parameters have been initialized including flowi4_oif, so when
> we call this function again, the process in __ip_route_output_key()
> will be different because of the setting of flowi4_oif, and we'll
> get a networking device which corresponds to the inputted flowi4_oif
> as the output device, this is wrong because we'll never hit this
> place if the previously returned source address of dst match one
> of the bound addresses.
> 
> To reproduce this problem, a vlan setting is enough:
>   # ifconfig eth0 up
>   # route del default
>   # vconfig add eth0 2
>   # vconfig add eth0 3
>   # ifconfig eth0.2 10.0.1.14 netmask 255.255.255.0
>   # route add default gw 10.0.1.254 dev eth0.2
>   # ifconfig eth0.3 10.0.0.14 netmask 255.255.255.0
>   # ip rule add from 10.0.0.14 table 4
>   # ip route add table 4 default via 10.0.0.254 src 10.0.0.14 dev eth0.3
>   # sctp_darn -H 10.0.0.14 -P 36422 -h 10.1.4.134 -p 36422 -s -I
> You'll detect that all the flow are routed to eth0.2(10.0.1.254).
> 
> Signed-off-by: Xufeng Zhang <xufeng.zhang@windriver.com>
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
> Changelog:
> 
> v1->v2:
>  Suggested by Julian Anastasov, reset flowi parameters by flowi4_update_output().
> 
>  net/sctp/protocol.c |    7 ++++++-
>  1 files changed, 6 insertions(+), 1 deletions(-)

<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read Documentation/stable_kernel_rules.txt
for how to do this properly.

</formletter>
