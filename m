From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH][ATM]: [lanai] ioctl only meant for debugging (from mitch@sfgoth.com)
Date: Mon, 22 Sep 2003 19:00:17 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030922190017.A27677@infradead.org>
References: <hch@infradead.org> <200309221755.h8MHt5kT010184@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, davem@redhat.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas williams <chas@cmf.nrl.navy.mil>
Content-Disposition: inline
In-Reply-To: <200309221755.h8MHt5kT010184@ginger.cmf.nrl.navy.mil>; from chas@cmf.nrl.navy.mil on Mon, Sep 22, 2003 at 01:55:07PM -0400
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Sep 22, 2003 at 01:55:07PM -0400, chas williams wrote:
> In message <20030922180749.A26432@infradead.org>,Christoph Hellwig writes:
> >Umm, shouldn't you just ifdef out the whole function and it's
> >assignment to the operations vector?  This looks horribly ugly..
> 
> i suppose i am not convinced that two #ifdef/#endif's are better than an
> #if/#else/#endif

first ifdefs in a function are always worse than around functions,
second ifdefs in a function that make it a stuv are pretty ugly and
third your (void)arg crap is ugly as hell. (what compiler do you have
that complains about this, btw, gcc 3.3 doesn't..).

So if you prefer one if/else/endif you can do it as

#if FOO
foo_ioctl()
{
}
#else
#define foo_ioctl	NULL
#endif

but in the case of assigning a function pointer to an operation vector
I find this more confusing than the above variant. 

---end quoted text---
