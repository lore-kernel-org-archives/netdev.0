From: "David S. Miller" <davem@redhat.com>
Subject: Re: [IPSEC] Fix xfrm_tunnel leak
Date: Tue, 1 Jun 2004 12:35:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040601123542.48e364e4.davem@redhat.com>
References: <20040601122559.GA19761@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040601122559.GA19761@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 1 Jun 2004 22:25:59 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Turns out that the IPIP tunnel used by IPCOMP states are only freed
> if the IPCOMP state is deleted by xfrm_state_delete.
> 
> This is not the case for all states.  For example, an immature IPCOMP
> state that dies in add_sa will not go through xfrm_state_delete.
> 
> The following patch moves the delete_tunnel call into IPCOMP's
> destructor.  I think it makes more sense there as IPCOMP is the
> only user of the tunnel anyway.

Looks perfect, patch applied.

Thanks Herbert.
