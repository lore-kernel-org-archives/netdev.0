From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] powerpc: ibmveth: Harden driver initilisation for kexec
Date: Thu, 02 Mar 2006 20:04:39 -0500
Message-ID: <44079627.6070100@pobox.com>
References: <20060131041055.5623C68A46@ozlabs.org>
	<20060131042903.GF28896@krispykreme> <44074A22.8060705@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: michael@ellerman.id.au, linuxppc64-dev@ozlabs.org,
	Paul Mackerras <paulus@samba.org>, anton@samba.org, netdev@vger.kernel.org
Return-path: <linuxppc64-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: Santiago Leon <santil@us.ibm.com>
In-Reply-To: <44074A22.8060705@us.ibm.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc64-dev>
List-Post: <mailto:linuxppc64-dev@ozlabs.org>
List-Help: <mailto:linuxppc64-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc64-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc64-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Santiago Leon wrote:
> From: Michael Ellerman <michael@ellerman.id.au>
> 
> After a kexec the veth driver will fail when trying to register with the
> Hypervisor because the previous kernel has not unregistered.
> 
> So if the registration fails, we unregister and then try again.
> 
> Signed-off-by: Michael Ellerman <michael@ellerman.id.au>
> Acked-by: Anton Blanchard <anton@samba.org>
> Signed-off-by: Santiago Leon <santil@us.ibm.com>
> ---
> 
>  drivers/net/ibmveth.c |   32 ++++++++++++++++++++++++++------
>  1 files changed, 26 insertions(+), 6 deletions(-)
> 
> Looks good to me, and has been around for a couple of months.

This seems completely bonkers to me:

	are resources available?
	if no
		free resources
		try again

It makes resource checking pointless.

	Jeff
