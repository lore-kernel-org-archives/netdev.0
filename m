From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] net: skb_orphan on dev_hard_start_xmit
Date: Fri, 03 Jul 2009 20:02:54 -0700 (PDT)
Message-ID: <20090703.200254.172991821.davem@davemloft.net>
References: <20090602.171418.186096253.davem@davemloft.net>
	<20090703075530.GA25190@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: patrick.ohly@intel.com, libertas-dev@lists.infradead.org, dcbw@redhat.com,
        netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
        rolandd@cisco.com, divy@chelsio.com, xemul@openvz.org
To: herbert@gondor.apana.org.au
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20090703075530.GA25190@gondor.apana.org.au>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 3 Jul 2009 15:55:30 +0800

> Calling skb_orphan like this should be forbidden.  Apart from the
> problems already raised, it is a sign that the driver is trying to
> paper over a more serious issue of not cleaning up skb's timely.
> 
> Yes skb_orphan will work for the cases where calling the skb
> destructor allows forward progress, but for the cases where you
> really need to the skb to be freed (e.g., iSCSI or Xen), this
> simply doesn't work.
> 
> So anytime someone tries to propose such a solution it is a sign
> that they have bigger problems.

Agreed, but alas we are foaming at the mouth until we have a truly
usable alternative.

In particular the case of handling a device without usable TX
completion event indications is still quite troublesome.
