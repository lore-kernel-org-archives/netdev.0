From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Refine IPv6 Address Validation Timer
Date: Sat, 28 Sep 2002 01:14:39 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020928.011439.108856769.yoshfuji@linux-ipv6.org>
References: <20020928.001617.91124319.yoshfuji@linux-ipv6.org>
	<200209271530.TAA21206@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200209271530.TAA21206@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <200209271530.TAA21206@sex.inr.ac.ru> (at Fri, 27 Sep 2002 19:30:14 +0400 (MSD)), kuznet@ms2.inr.ac.ru says:

> Let's only delete this:
> 
> > +	if (time_before(now + HZ/2, jiffies)) {
> > +		ADBG((KERN_WARNING 
> > +		      "addrconf_verify(): too slow; jiffies - now = %ld\n",
> > +		      (long)jiffies - (long)now));
> > +	}
> 
> I do not understand how this survived. If you worry about infinite
> spinning in loop you could make this check real, f.e. breaking loop
> when jiffies >= now+2. In this form it is just mud.

hmm, I supposed it finally exited the loop (and then we got above warn).
Code around end of patch (*) prevent continuous run of this function.
If it is (almost) meaningless, just delete it.

(*) Oops, I slipped at (almost) end of the patch when making patch... sorry;
I inteded to refine timing into ~0.5 sec at worst; so, please change
	addr_chk_timer.expires = time_before(next, jiffies + HZ) ? jiffies + HZ : next;
to
	addr_chk_timer.expires = time_before(next, jiffies + HZ/2) ? jiffies + HZ/2 : next;
.

Thanks.


(do I need to resend complete patch?)

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
