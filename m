From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_unix: Don't set err in unix_stream_read_generic
 unless there was an error
Date: Tue, 16 Feb 2016 12:51:57 -0500 (EST)
Message-ID: <20160216.125157.1927195719504877809.davem@davemloft.net>
References: <87bn7rtdwe.fsf@doppelsaurus.mobileactivedefense.com>
	<87twljrsb1.fsf@doppelsaurus.mobileactivedefense.com>
	<87bn7rrqdk.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, edumazet@google.com,
	dhowells@redhat.com, ying.xue@windriver.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org, joseph.salisbury@canonical.com
To: rweikusat@mobileactivedefense.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <87bn7rrqdk.fsf@doppelsaurus.mobileactivedefense.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Date: Mon, 08 Feb 2016 18:47:19 +0000

> The present unix_stream_read_generic contains various code sequences of
> the form
> 
> err = -EDISASTER;
> if (<test>)
> 	goto out;
> 
> This has the unfortunate side effect of possibly causing the error code
> to bleed through to the final
> 
> out:
> 	return copied ? : err;
> 
> and then to be wrongly returned if no data was copied because the caller
> didn't supply a data buffer, as demonstrated by the program available at
> 
> http://pad.lv/1540731
> 
> Change it such that err is only set if an error condition was detected.
> 
> Fixes: 3822b5c2fc62 ("af_unix: Revert 'lock_interruptible' in stream receive code")
> Reported-by: Joseph Salisbury <joseph.salisbury@canonical.com>
> Signed-off-by: Rainer Weikusat <rweikusat@mobileactivedefense.com>

Applied, thanks Rainer.

And BTW I disagree with some of the feedback I saw in these threads
about "if (x) goto out;" being unreadable and that it should be avoided.

That's completely wrong.

Fact is, we've all been reading code of that form for multiple decades.
So it's the style we are _MOST_ familiar with, and it is therefore the
style that is the easiest and clearest for kernel developers to understand.

Especially those of us who review hundreds of patches per day.

And it doesn't matter at all what the compiler does underneath.

Furthermore, such a style works best in the long term because if real
cleanup operations are added for exit from the function, less has to
change and such patches are therefore significantly easier to review.
