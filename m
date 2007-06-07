From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: warnings in git-wireless
Date: Wed, 6 Jun 2007 18:04:21 -0700
Message-ID: <20070606180421.c575f24b.akpm@linux-foundation.org>
References: <20070605020614.3f06b2ab.akpm@linux-foundation.org>
	<46671E5D.9070304@linux.intel.com>
	<20070606163534.6a6cffb7.akpm@linux-foundation.org>
	<4667364A.4040803@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	linux-sparse@vger.kernel.org
To: James Ketrenos <jketreno@linux.intel.com>
Return-path: <linux-sparse-owner@vger.kernel.org>
In-Reply-To: <4667364A.4040803@linux.intel.com>
Sender: linux-sparse-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 06 Jun 2007 15:33:46 -0700 James Ketrenos <jketreno@linux.intel.com> wrote:

> Andrew Morton wrote:
> > On Wed, 06 Jun 2007 13:51:41 -0700 James Ketrenos <jketreno@linux.intel.com> wrote:
> > 
> >>>>  * make C=2 CF=-Wall will complain if you use ARRAY_SIZE on global data
> >>>>  */
> >>>> #define GLOBAL_ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
> >>> This is identical to ARRAY_SIZE.
> >>>
> >>> And if there's some problem with ARRAY_SIZE then fix ARRAY_SIZE!  Don't go 
> >>> off and create some private thing and leave everyone else twisting in the
> >>> wind.
> >> The code was resolving the sparse warnings.  
> > 
> ...
> > Your GLOBAL_ARRAY_SIZE() is, afaict, identical to ARRAY_SIZE().
> 
> >From include/linux/kernel.h
> 
> #define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]) + __must_be_array(arr))

o crap, sorry, I was looking at one of the other definitions of ARRAY_SIZE :(


> >From drivers/net/wireless/mac80211/iwlwifi/iwl-helpers.h
> 
> #define GLOBAL_ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
> 
> The '+ __must_be_array(arr)' part of ARRAY_SIZE was causing sparse to complain 
> with:
> 
> drivers/net/wireless/mac80211/iwlwifi/base.c:4646:22: error: cannot size expression
> ...

OK, that's a problem in sparse, I guess.

There _should_ be some #ifdeffable thing which is being passed to cpp when
we run sparse (but I'm not sure what it is).  If there is such a thing then
we could disable the __must_be_array() thing during sparse runs.

But longer-term, sparse should be taught about __must_be_array().

> When I had run my builds, I had restricted the sparse checks to just iwlwifi 
> (vs. checking the rest of the kernel).
> 
> I just ran it C=2 CF=-Wall against the rest of the kernel and do see other code 
> with the same problem, eg:
> 
> sound/core/memalloc.c:521:14: error: cannot size expression
> ...
> 
> I had erroneously thought it was just a problem with iwlwifi...
> 
