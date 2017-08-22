From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH RESEND 0/2] enable hires timer to timeout datagram socket
Date: Tue, 22 Aug 2017 08:23:11 +0200
Message-ID: <20170822062311.okn7coroki2fjgyc@localhost>
References: <1503081850-10671-1-git-send-email-vallish@amazon.com>
 <20170818201854.xes246oviptinwvq@localhost>
 <20170818222756.GB28737@amazon.com>
 <20170819062145.vtr63ri4v577cymz@localhost>
 <20170820014744.GA43685@amazon.com>
 <20170821182210.GA2983@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, shuah@kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, eduval@amazon.com,
        anchalag@amazon.com, tglx@linutronix.de
To: Vallish Vaidyeshwara <vallish@amazon.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170821182210.GA2983@amazon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 21, 2017 at 06:22:10PM +0000, Vallish Vaidyeshwara wrote:
> AWS Lambda is affected by this change in behavior in
> system call. Following links has more information:
> https://en.wikipedia.org/wiki/AWS_Lambda

Quote:

    Unlike Amazon EC2, which is priced by the hour, AWS Lambda is
    metered in increments of 100 milliseconds.

So I guess you want the accurate timeout in order to support billing?
In any case, even with the old wheel you didn't have guarantees WRT
timeout latency, and so the proper way for the application to handle
this is to use a timerfd together with HIGH_RES_TIMERS, and PREEMPT_RT
in order to have sub-millisecond latency.

Thanks,
Richard
