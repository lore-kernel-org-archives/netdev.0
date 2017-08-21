From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH RESEND 1/2] net: enable high resolution timer mode to
 timeout datagram sockets
Date: Mon, 21 Aug 2017 13:10:34 -0700
Message-ID: <CAM_iQpUxS91BGYU7FOwq65Ln_9bbMO1YRzA2+xJDYh399du7mQ@mail.gmail.com>
References: <1503081850-10671-1-git-send-email-vallish@amazon.com> <1503081850-10671-2-git-send-email-vallish@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>, shuah@kernel.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eduardo Valentin <eduval@amazon.com>, anchalag@amazon.com
To: Vallish Vaidyeshwara <vallish@amazon.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503081850-10671-2-git-send-email-vallish@amazon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 18, 2017 at 11:44 AM, Vallish Vaidyeshwara
<vallish@amazon.com> wrote:
> -       *timeo_p = schedule_timeout(*timeo_p);
> +       /* Wait using highres timer */
> +       expires = ktime_add_ns(ktime_get(), jiffies_to_nsecs(*timeo_p));
> +       pre_sched_time = jiffies;
> +       if (schedule_hrtimeout(&expires, HRTIMER_MODE_ABS))

Does this work with MAX_SCHEDULE_TIMEOUT too??
