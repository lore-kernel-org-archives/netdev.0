From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH ethtool] ethtool: Support for configurable RSS hash
 function
Date: Wed, 29 Mar 2017 10:49:22 -0400
Message-ID: <20170329144921.GC18103@tuxdriver.com>
References: <1488981831-19376-1-git-send-email-galp@mellanox.com>
 <20170325145047.6a5a7967@cakuba.netronome.com>
 <20170327180203.GB29050@tuxdriver.com>
 <29780e3c-b8df-a4f7-72f5-53e94bd448b4@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jakub Kicinski <kubakici@wp.pl>, netdev@vger.kernel.org,
        Eyal Perry <eyalpe@mellanox.com>
To: Gal Pressman <galp@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59538 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751254AbdC2PAR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 11:00:17 -0400
Content-Disposition: inline
In-Reply-To: <29780e3c-b8df-a4f7-72f5-53e94bd448b4@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 29, 2017 at 02:56:38PM +0300, Gal Pressman wrote:
> On 27/03/2017 21:02, John W. Linville wrote:
> > On Sat, Mar 25, 2017 at 02:50:47PM -0700, Jakub Kicinski wrote:
> >> On Wed,  8 Mar 2017 16:03:51 +0200, Gal Pressman wrote:
> >>> This ethtool patch adds support to set and get the current RSS hash
> >>> function for the device through the new hfunc mask field in the
> >>> ethtool_rxfh struct. Kernel supported hash function names are queried
> >>> with ETHTOOL_GSTRINGS - each string is corresponding with a bit in hfunc
> >>> mask according to its index in the string-set.
> >>>
> >>> Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
> >>> Signed-off-by: Gal Pressman <galp@mellanox.com>
> >>> Reviewed-by: Saeed Mahameed <saeedm@mellanox.com>
> >> Hi John,
> >>
> >> It seems you have applied both my earlier patch with get support and
> >> this:
> >>
> >> adbaa18b9bc1 ("ethtool: Support for configurable RSS hash function")
> >> b932835d2302 ("ethtool: print hash function with ethtool -x|--show-rxfh-indir")

Damn it! I was bamboozled...

> >> Now we print the RSS function twice:
> >>
> >> RX flow hash indirection table for em4 with 4 RX ring(s):
> >>     0:      [...]
> >> RSS hash function: toeplitz  <--- from my adbaa18b9bc1

This should have said "<--- from my b932835d2302"...

> >> RSS hash key:
> >> Operation not supported
> >> RSS hash function:           <--- from this patch
> >>     toeplitz: on
> >>     xor: off
> >>     crc32: off
> >>
> >> Reverting my patch is probably the easiest way forward, although I find
> >> it more concise and easier to parse in test scripts :)
> > Thanks for pointing-out this issue! I apologize for my own confusion.
> >
> > As you suggest, I will be reverting your patch.
> >
> > Thanks,
> >
> > John
> 126464e4da18 ('Revert "ethtool: Support for configurable RSS hash function"')
> 
> Seems like you ended up reverting my patch instead of Jakub's?
> We lost the set hfunc functionality.

Confused by the swapped commit IDs above, I dutifully reverted
"adbaa18b9bc1"...ugh...

Alright, I'll have to tighten-up my game a bit! From here I'll revert
b932835d2302 and reinstate adbaa18b9bc1, hopefully bringing this
little misadventure to a close.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
