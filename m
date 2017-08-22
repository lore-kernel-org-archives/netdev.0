From: Vallish Vaidyeshwara <vallish@amazon.com>
Subject: Re: [PATCH RESEND 1/2] net: enable high resolution timer mode to
 timeout datagram sockets
Date: Tue, 22 Aug 2017 11:14:34 +0000
Message-ID: <20170822111433.GA102755@amazon.com>
References: <1503081850-10671-1-git-send-email-vallish@amazon.com>
 <1503081850-10671-2-git-send-email-vallish@amazon.com>
 <CAM_iQpUxS91BGYU7FOwq65Ln_9bbMO1YRzA2+xJDYh399du7mQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>, <shuah@kernel.org>,
        "Linux Kernel Network Developers" <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eduardo Valentin <eduval@amazon.com>, <anchalag@amazon.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAM_iQpUxS91BGYU7FOwq65Ln_9bbMO1YRzA2+xJDYh399du7mQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 21, 2017 at 01:10:34PM -0700, Cong Wang wrote:
> On Fri, Aug 18, 2017 at 11:44 AM, Vallish Vaidyeshwara
> <vallish@amazon.com> wrote:
> > -       *timeo_p = schedule_timeout(*timeo_p);
> > +       /* Wait using highres timer */
> > +       expires = ktime_add_ns(ktime_get(), jiffies_to_nsecs(*timeo_p));
> > +       pre_sched_time = jiffies;
> > +       if (schedule_hrtimeout(&expires, HRTIMER_MODE_ABS))
>

Hello Cong,

> Does this work with MAX_SCHEDULE_TIMEOUT too??
> 

Thanks for pointing out MAX_SCHEDULE_TIMEOUT. I have made minor change to
accommodate MAX_SCHEDULE_TIMEOUT and will send out next version of the patch
for review.

Thanks.
-Vallish
