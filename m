From: Luciano Coelho <luciano.coelho@intel.com>
Subject: Re: [PATCH 1/3] wireless: iwlwifi: use bool instead of int
Date: Wed, 04 Oct 2017 22:18:51 +0300
Message-ID: <1507144731.908.108.camel@intel.com>
References: <20171004155700.18048-1-christoph@boehmwalder.at>
         <20171004155700.18048-2-christoph@boehmwalder.at>
         <1507134405.4434.10.camel@perches.com> <1507135159.908.96.camel@intel.com>
         <1507139722.4434.12.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>,
        Christoph =?ISO-8859-1?Q?B=F6hmwalder?=
        <christoph@boehmwalder.at>, johannes.berg@intel.com,
        emmanuel.grumbach@intel.com, kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507139722.4434.12.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-10-04 at 10:55 -0700, Joe Perches wrote:
> On Wed, 2017-10-04 at 19:39 +0300, Luciano Coelho wrote:
> > On Wed, 2017-10-04 at 09:26 -0700, Joe Perches wrote:
> 
> []
> > > This might be more intelligble as separate tests
> > > 
> > > static bool is_valid_channel(u16 ch_id)
> > > {
> > > 	if (ch_id <= 14)
> > > 		return true;
> > > 
> > > 	if ((ch_id % 4 == 0) &&
> > > 	    ((ch_id >= 36 && ch_id <= 64) ||
> > > 	     (ch_id >= 100 && ch_id <= 140)))
> > > 		return true;
> > > 
> > > 	if ((ch_id % 4 == 1) &&
> > > 	    (chid >= 145 && ch_id <= 165))
> > > 		return true;
> > > 
> > > 	return false;
> > > }
> > > 
> > > The compiler should produce the same object code.
> > 
> > Yeah, it may be a bit easier to read, but I don't want to start
> > getting
> > "fixes" to working and reasonable code.  There's nothing wrong with
> > the
> > existing function (except maybe for the int vs. boolean) so let's
> > not
> > change it.
> > 
> > A good time to change this would be the next time someone adds yet
> > another range of valid channels here. ;)
> 
> <shrug>  Your choice.
> 
> I like code I can read and understand at a glance.

I do too, but I don't think the original is that hard to read, really. 
Each "if" you add is already corresponding to one separate line in the
original code...


> At case somebody needs to add channels, likely nobody
> would do the change suggested but would just add
> another test to the already odd looking block.

Yeah, that would most likely be the case, but if I saw that and thought
there was a better way to write it, believe me, I would definitely
nitpick the patch and ask the author to reorg the code so it would look
nicer.


> And constants should be on the right side of the tests.

Sure, in a new patch, we would definitely pay attention to that.  But
now, is it worth having one more patch go through the entire machinery
to change a relatively clear, extremely simple function just because
you could write it in a different way? My answer is a resounding no,
sorry.

--
Luca.
