From: "David S. Miller" <davem@redhat.com>
Subject: Re: net/sctp/sm_make_chunk.c alignment problems on parisc64
Date: Thu, 18 Sep 2003 19:55:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030918195525.28c17cb1.davem@redhat.com>
References: <20030912164628.GF8713@conectiva.com.br>
	<Pine.LNX.4.44.0309171559540.3831-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, netdev@oss.sgi.com,
        lksctp-developers@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0309171559540.3831-100000@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 17 Sep 2003 16:06:18 -0700 (PDT)
Sridhar Samudrala <sri@us.ibm.com> wrote:

> I don't see this problem on i386, ia64 or ppc64. Can someone
> familiar with parisc64 provide more details or submit a a patch to
> fix this problem?

As an example, if you have an structure member of type "char":

struct foo {
	char	a;
	char	b[4];
};

And then try to do something like this:

	struct foo *p;
	unsigned int *v;

	v = (unsigned int *) (&p->b[0]);
	*v = 0;

The build is going to explode on parisc because this simply is not
allowed.  You cannot access a structure member as an object which
has larger alignment than is guarenteed for the type that member
has.

In the above example we're trying to access with 'unsigned int'
alignment a member which is only guarenteed to have the alignment
for a 'char'.
