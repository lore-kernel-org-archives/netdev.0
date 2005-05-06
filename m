From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: resend patch:  xfrm policybyid
Date: Fri, 6 May 2005 18:54:05 +1000
Message-ID: <20050506085404.GA26719@gondor.apana.org.au>
References: <1115298877.7680.75.camel@localhost.localdomain> <20050505213239.GA29526@gondor.apana.org.au> <1115331436.8006.112.camel@localhost.localdomain> <20050505231210.GA30574@gondor.apana.org.au> <1115342122.7660.25.camel@localhost.localdomain> <20050506013125.GA31780@gondor.apana.org.au> <1115345403.7660.49.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1115345403.7660.49.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 05, 2005 at 10:10:03PM -0400, jamal wrote:
> 
> > The way I'm seeing it is that the index is simply a read-only value
> > that's only provided by the kernel to the user as an aid in locating
> > policies.
> 
> IOW, they are search keys. 

I'm afraid I still disagree.  There should only be one key that the
user gets to set when adding policies that is guaranteed to be unique.
As it is it's the selector.

Letting the user specify two independent keys which need to be unique
is what is making your patch ugly and what IMHO will make the code
unmaintainable.

Here is an analogy.  Think of the policies as files and the indicies
as file descriptors.  The index is only valid while the policy is in
the policy list (the file descriptor is only valid while the file is
open).  When you add the policy, you don't get to specify what the
index is (when you open a file, you don't get to specify what the
file descriptor is).  Once the policy has been added, you will be
given an index that you can use to read/delete the policy (once the
file has been opened, you will be given a file descriptor that you
can use to access/close the file).

Now you may argue that file descriptors can be set to whatever value
you want using dup.  However, the difference here is that you can
only do this on an open file.  Similarly, changing the index of a
policy that's already in the list can be done cleanly since we
already have verified that its primary key (the selector) is unique.

However, I must say that I still have absolutely no idea why anyone
would need to set the index to arbitrary values.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
