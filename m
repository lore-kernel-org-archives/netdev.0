From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: net/sctp/sm_make_chunk.c alignment problems on parisc64
Date: Sat, 20 Sep 2003 12:54:05 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030920155404.GA29040@conectiva.com.br>
References: <20030918195525.28c17cb1.davem@redhat.com> <Pine.LNX.4.44.0309191440320.4758-100000@localhost.localdomain> <20030919233909.7ec3aab0.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>, netdev@oss.sgi.com,
        lksctp-developers@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030919233909.7ec3aab0.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Fri, Sep 19, 2003 at 11:39:09PM -0700, David S. Miller escreveu:
> On Fri, 19 Sep 2003 15:15:53 -0700 (PDT)
> Sridhar Samudrala <sri@us.ibm.com> wrote:
> 
> > But unfortunately i am not able see this problem with a parisc64 cross compiler 
> > on i386. So it makes it hard to debug or fix it. Looks like this happens only
> > when building natively on a parisc64 machine which i don't have access to.
> 
> Did you build with or without SMP enabled?

Yes, here I'm building without SMP enabled.

> Anyways, try to work with Arnaldo to figure out the precise statement
> causing the problems.

The problem is right at:

tv_add(&asoc->cookie_life, &cookie->c.expiration);

and more specifically the problem is with cookie->c.expiration, that in
turn points to this line:

cookie = (struct sctp_signed_cookie *) retval->body;

Now retval is of this type:

/* Section 3.3.3.1 State Cookie (7) */
typedef struct sctp_cookie_param {
        sctp_paramhdr_t p;
        __u32 body[0];
} sctp_cookie_param_t __attribute__((packed));

I removed the packed attribute both from sctp_cookie_param_t and
sctp_paramhdr_t, the problem persists, ideas?

Please send any patch you come up with, I'll be happy to test it.

- Arnaldo
