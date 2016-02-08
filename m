From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [V4.4-rc6 Regression] af_unix: Revert 'lock_interruptible' in
 stream receive code
Date: Sun, 07 Feb 2016 19:35:02 -0800
Message-ID: <1454902502.7627.360.camel@edumazet-glaptop2.roam.corp.google.com>
References: <56B4EF04.2060407@canonical.com>
	 <87bn7ude8g.fsf@doppelsaurus.mobileactivedefense.com>
	 <1454713398.7627.325.camel@edumazet-glaptop2.roam.corp.google.com>
	 <8737t4jr99.fsf@doppelsaurus.mobileactivedefense.com>
	 <87io20upk9.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hannes@stressinduktion.org,
	edumazet@google.com, dhowells@redhat.com, ying.xue@windriver.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	Joseph Salisbury <joseph.salisbury@canonical.com>
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87io20upk9.fsf@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2016-02-07 at 22:24 +0000, Rainer Weikusat wrote:
> Rainer Weikusat <rw@doppelsaurus.mobileactivedefense.com> writes:
> 
> [...]
> 
> > The start uses that to record an error which might need to be
> > reported, the return statement uses it to indicate that an error has
> > occurred. Hence, some kind of in-between translation must occur.  The
> > mutex_lock_interruptible happened to do that but that was never it's
> > intended purpose.
> 
> Additional information: The 'trick' of using recvmsg w/o a receive
> buffer in order to retrieve control messages in fact wouldn't have
> worked with the unix_stream_recvmsg prior to introduction of the
> interruptible lock as that (judging from the git source) would have
> triggered all the same issues,
> 
> 	- -EOPNOTSUP if a msg was available
> 
>         - -EAGAIN if the code had to wait
> 
>         - not receiving the creds if the -EAGAIN hadn't happened because
>           of the continue (that's the other patch)
> 
> IOW, that's a feature inadvertendly added by an otherwise useless code
> change (mea culpa).

This is exactly the needed information for stable teams.

Goal is here is not to blame someone (you, me ... it does not matter) ,
but give to stable teams the point the problem showed up.

See the 'Fixes' tag as a time saver for people like me.

It is incredibly useful when hutting bugs, because each commit can
easily point to the 'bug origin'.

Having spent time lately in af_unix code insanity, I really can tell.

At the time someone fixes a bug, he/she has a clear view of what is
happening, but months later, he/she often has to start again the commits
analysis.

Thanks a lot.
