From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Divide error in bictcp_cong_avoid ?
Date: Wed, 4 May 2011 12:37:38 -0700
Message-ID: <20110504123738.7bb4d1ee@nehalam>
References: <4DC178D3.6030308@techboom.com>
	<20110504104940.cd0d9e9a.rdunlap@xenotime.net>
	<20110504113351.4643a0c9@nehalam>
	<16668.1304537481@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <rdunlap@xenotime.net>, TB <lkml@techboom.com>,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <16668.1304537481@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 04 May 2011 15:31:21 -0400
Valdis.Kletnieks@vt.edu wrote:

> On Wed, 04 May 2011 11:33:51 PDT, Stephen Hemminger said:
> 
> > What kernel version? I suspect they are running something really old
> > kernel like RHEL 5 since BIC has not been the default congestion control for
> > several years.
> 
> Pretty bleeding edge here, and BIC is *still* the default:
> 
> % uname -a
> Linux turing-police.cc.vt.edu 2.6.39-rc5-mmotm0429 #1 SMP PREEMPT Sat Apr 30 00:36:49 EDT 2011 x86_64 x86_64 x86_64 GNU/Linux
> % zgrep -i BIC /proc/config.gz 
> CONFIG_TCP_CONG_BIC=y
> CONFIG_TCP_CONG_CUBIC=m
> CONFIG_DEFAULT_BIC=y
> CONFIG_DEFAULT_TCP_CONG="bic"
> 
> Why? Because BIC was working "well enough", so I never changed it by hand, and
> "make oldconfig" never changed it automagically either.  Now, 
> 

The CUBIC code has the same function names so that is where the
problem is.

Don't use BIC, it is known to be unfair between flows.
The configuration process never changes your values, it only asks
about new ones.

-- 
