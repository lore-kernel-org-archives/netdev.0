From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH v2 net-next] xfrm: Fix unaligned access to stats in
 copy_to_user_state()
Date: Fri, 23 Oct 2015 12:33:17 +0200
Message-ID: <20151023103317.GN7701@secunet.com>
References: <20151021154722.GA14667@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<herbert@gondor.apana.org.au>, <davem@davemloft.net>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151021154722.GA14667@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 21, 2015 at 11:48:25AM -0400, Sowmini Varadhan wrote:
> 
> On sparc, deleting established SAs (e.g., by restarting ipsec)
> results in unaligned access messages via xfrm_del_sa -> 
> km_state_notify -> xfrm_send_state_notify().
> 
> Even though struct xfrm_usersa_info is aligned on 8-byte boundaries,
> netlink attributes are fundamentally only 4 byte aligned, and this
> cannot be changed for nla_data() that is passed up to userspace.
> As a result, the put_unaligned() macro needs to be used to
> set up potentially unaligned fields such as the xfrm_stats in
> copy_to_user_state()
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
> v2: review comment from thread: cannot use PTR_ALIGN as this would break
>     userspace assumptions about 4 byte alignment. Use *_unaligned() macros
>     as needed, instead.

This works on intel 32-bit and 64-bit as expected.
Patch applied to ipsec-next, thanks!
