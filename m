From: Christoph Lameter <christoph@lameter.com>
Subject: Re: atomic_dec_and_test for child dst needed in dst_destroy?
Date: Tue, 5 Apr 2005 20:19:55 -0700 (PDT)
Message-ID: <Pine.LNX.4.58.0504051925250.21486@graphe.net>
References: <E1DJ08O-0003Ln-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1DJ08O-0003Ln-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 6 Apr 2005, Herbert Xu wrote:

> Christoph Lameter <christoph@lameter.com> wrote:
> >
> > If that is so then it is also possible that the gc frees after
> > atomic_dec_and_test:
>
> No this is prevented by the nohash check.

Ok then the purpose of this whole thing is to decrement the usage counter
and at the same time figure out if this is the last child on an unhashed
entry. That unhashed entry is not handled by the garbage collector and
must be freed separately.

The atomic_dec_and_test is needed because as soon as the refcnt reaches
zero the dst entry may potentially be freed by the garbage collector. Thus
no future access to the dst entry is possible and the dec_and_test is the
only safe way to figure out if the counter reached zero.

I hope I got it now. Thanks.
