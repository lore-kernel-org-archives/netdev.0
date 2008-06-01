From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: howto use ioremap_wc?
Date: Sat, 31 May 2008 18:54:24 -0700
Message-ID: <20080531185424.1cd18220@infradead.org>
References: <4841143E.5080003@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	"venkatesh.pallipadi@intel.com" <venkatesh.pallipadi@intel.com>
To: Brice Goglin <brice@myri.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756724AbYFAByo@vger.kernel.org>
In-Reply-To: <4841143E.5080003@myri.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 31 May 2008 11:02:54 +0200
Brice Goglin <brice@myri.com> wrote:

> Hello,
> 
> We're looking at using ioremap_wc() in myri10ge. No drivers seem to be
> using it yet, so I'd like to get some clarification regarding
> ioremap_wc failures, MTRR and so on.
> 
> What we currently do is mtrr_add() and then ioremap. Depending on the
> mtrr_add() success, we use the "wc_fifo" or regular PIO with fences to
> submit requests to the NIC. 

Ok this leads to a question: since write combining is effectively an
extension (eg relaxation) to uncached, how much do you care if you
actually get uncached? Eg can you just use the "WC" function even for
the case where you get an uncached mapping ?

> How are we supposed to switch this to
> ioremap_wc?
> 
> Are we sure that if the arch supports _wc, it does not return success
> when the underlying plain ioremap worked but setting up _wc() failed?

why would it not return success? You asked for a mapping with a set of
guarantees, and you got something that adheres to those guarantees (and
then some ;(...

Would you expect ioremap_cache() to fail if you couldn't get a cachable
mapping? That would suck (hint: on PC's it will then fail 99.9% of the
time)....

> If so, why does it revert to ioremap_nocache when PAT isn't enabled?

Actually it would make sense for the ioremap_wc() implementation to try
to add an mtrr I suppose... it's better to be done there than trying to
do it in some driver....

-- 
If you want to reach me at my work email, use arjan@linux.intel.com
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
