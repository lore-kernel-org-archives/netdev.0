From: Andrew Morton <akpm@digeo.com>
Subject: Re: [RFC][PATCH] net drivers and cache alignment
Date: Sat, 07 Dec 2002 15:29:16 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DF2844C.F9216283@digeo.com>
References: <3DF2781D.3030209@pobox.com> <20021207.144004.45605764.davem@redhat.com> <3DF27EE7.4010508@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> 
> David S. Miller wrote:
> > Can't the cacheline_aligned attribute be applied to individual
> > struct members?  I remember doing this for thread_struct on
> > sparc ages ago.
> 
> Looks like it from the 2.4 processor.h code.
> 
> Attached is cut #2.  Thanks for all the near-instant feedback so far :)
>   Andrew, does the attached still need padding on SMP?

It needs padding _only_ on SMP.  ____cacheline_aligned_in_smp.

#define offsetof(t, m)  ((int)(&((t *)0)->m))

struct foo {
        int a;
        int b __attribute__((__aligned__(1024)));
        int c;
} foo;

main()
{
        printf("%d\n", sizeof(struct foo));
        printf("%d\n", offsetof(struct foo, a));
        printf("%d\n", offsetof(struct foo, b));
        printf("%d\n", offsetof(struct foo, c));
}

./a.out
2048
0
1024
1028

So your patch will do what you want it to do.  You should just tag the
first member of a group with ____cacheline_aligned_in_smp, and keep an
eye on things with offsetof().

Not sure why sizeof() returned 2048 though.
