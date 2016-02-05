From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [V4.4-rc6 Regression] af_unix: Revert 'lock_interruptible' in
 stream receive code
Date: Fri, 05 Feb 2016 15:03:18 -0800
Message-ID: <1454713398.7627.325.camel@edumazet-glaptop2.roam.corp.google.com>
References: <56B4EF04.2060407@canonical.com>
	 <87bn7ude8g.fsf@doppelsaurus.mobileactivedefense.com>
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
In-Reply-To: <87bn7ude8g.fsf@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-02-05 at 21:44 +0000, Rainer Weikusat wrote:
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


Well, if you replace the traditional flow

err = -XXXX;
if (test)
     goto out;

Then please add unlikely() to at least give a hint to the compiler.

if (unlikely(test)) {
    err = -XXX;
    goto out;
}

And please add a 'Fixes: .... ' tag for bug fixes.

Thanks.
