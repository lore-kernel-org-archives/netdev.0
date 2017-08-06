From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: Re: [PATCH v06 18/36] uapi linux/errqueue.h: include linux/time.h in
 user space
Date: Sun, 6 Aug 2017 23:58:25 +0300
Message-ID: <20170806205825.GG28459@lakka.kapsi.fi>
References: <20170806164428.2273-1-mikko.rapeli@iki.fi>
 <20170806164428.2273-19-mikko.rapeli@iki.fi>
 <CAF=yD-L2ntuH54J_SwN9WcpBMgkV_v0e-Q2Pu2mrQ3+1RozGFQ@mail.gmail.com>
 <CAF=yD-LDo7_8k5rMtBkj-PASqTqz7Toub0qXBdGUR3Kqb4p4Tg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAF=yD-LDo7_8k5rMtBkj-PASqTqz7Toub0qXBdGUR3Kqb4p4Tg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 06, 2017 at 04:26:50PM -0400, Willem de Bruijn wrote:
> On Sun, Aug 6, 2017 at 4:23 PM, Willem de Bruijn
> <willemdebruijn.kernel@gmail.com> wrote:
> > On Sun, Aug 6, 2017 at 12:44 PM, Mikko Rapeli <mikko.rapeli@iki.fi> wrote:
> >> linux/time.h conflicts with user space header time.h. Try to be compatible
> >> with both.
> >>
> >> Fixes userspace compilation error:
> >>
> >> error: array type has incomplete element type
> >>  struct timespec ts[3];
> >>
> >> Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
> >> Cc: Willem de Bruijn <willemb@google.com>
> >> Cc: Soheil Hassas Yeganeh <soheil@google.com>
> >> Cc: netdev@vger.kernel.org
> >> ---
> >>  include/uapi/linux/errqueue.h | 6 ++++++
> >>  1 file changed, 6 insertions(+)
> >>
> >> diff --git a/include/uapi/linux/errqueue.h b/include/uapi/linux/errqueue.h
> >> index 07bdce1f444a..b310b2c6d94f 100644
> >> --- a/include/uapi/linux/errqueue.h
> >> +++ b/include/uapi/linux/errqueue.h
> >> @@ -3,6 +3,12 @@
> >>
> >>  #include <linux/types.h>
> >>
> >> +#ifdef __KERNEL__
> >> +#include <linux/time.h>
> >> +#else
> >> +#include <time.h>
> >> +#endif /* __KERNEL__ */
> >
> > This will break applications that include <linux/time.h> manually.
> 
> Also, the patch title reads "include <linux/time.h> in user space",
> but it includes <time.h> in that environment.

Oops, missed while squashing some commits. Will fix. Thanks!

-Mikko
