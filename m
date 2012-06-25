From: Samuel Ortiz <sameo@linux.intel.com>
Subject: Re: [PATCH] NFC: only put local on destruction if it was created
 before
Date: Mon, 25 Jun 2012 19:29:06 +0200
Message-ID: <20120625172906.GD16275@sortiz-mobl>
References: <1339531699-7377-1-git-send-email-levinsasha928@gmail.com>
 <20120625171738.GC16275@sortiz-mobl>
 <1340644546.31710.6.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lauro.venancio@openbossa.org, aloisio.almeida@openbossa.org,
	linville@tuxdriver.com, davej@redhat.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1340644546.31710.6.camel@lappy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 25, 2012 at 07:15:46PM +0200, Sasha Levin wrote:
> On Mon, 2012-06-25 at 19:17 +0200, Samuel Ortiz wrote:
> > Hi Sasha,
> > 
> > On Tue, Jun 12, 2012 at 10:08:19PM +0200, Sasha Levin wrote:
> > > Not having 'local' is a valid case when a socket was created but never
> > > bound or connected to anything, so avoid putting 'local' if it was
> > > never created.
> > > 
> > > Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> > > ---
> > >  net/nfc/llcp/sock.c |    3 ++-
> > >  1 files changed, 2 insertions(+), 1 deletions(-)
> > > 
> > > diff --git a/net/nfc/llcp/sock.c b/net/nfc/llcp/sock.c
> > > index 2c0b317..54daa10 100644
> > > --- a/net/nfc/llcp/sock.c
> > > +++ b/net/nfc/llcp/sock.c
> > > @@ -710,7 +710,8 @@ void nfc_llcp_sock_free(struct nfc_llcp_sock *sock)
> > >  
> > >  	sock->parent = NULL;
> > >  
> > > -	nfc_llcp_local_put(sock->local);
> > > +	if (sock->local)
> > > +		nfc_llcp_local_put(sock->local);
> > nfc_llcp_local_put() already checks for its argument being NULL or not.
> 
> nfc_llcp_local_put() triggers a warning in this case as well, which
> means that this code path shouldn't be happening.
> 
> Should we remove the WARN_ON from nfc_llcp_local_put() instead?
Yes, that would be better.

Cheers,
Samuel.

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
