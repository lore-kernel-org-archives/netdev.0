From: James Morris <jmorris@redhat.com>
Subject: Re: [CRYPTO] Fix stack overrun in crypt()
Date: Fri, 16 Jul 2004 11:27:36 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0407161126350.13406@devserv.devel.redhat.com>
References: <20040715114840.GA1325@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040715114840.GA1325@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 15 Jul 2004, Herbert Xu wrote:

> Hi:
> 
> The stack allocation in crypt() is bogus as whether tmp_src/tmp_dst
> is used is determined by factors unrelated to nbytes and
> src->length/dst->length.
> 
> Since the condition for whether tmp_src/tmp_dst are used is very
> complex, let's allocate them always instead of guessing.
> 
> This fixes a number of weird crashes including those AES crashes
> that people have been seeing with the 2.4 backport + ipt_conntrack.

Ok, thanks, looks good.

> PS I think someone should double-check the logic in the scatterwalk
> stuff, especially the whichbuf bits.

Adam Richter rewrote that code, and I have walked through it before (I 
guess Dave did too).  Any more code reviewers welcome.


- James
-- 
James Morris
<jmorris@redhat.com>
