From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: RFC: igb: Intel 82575 gigabit ethernet driver (take #2)
Date: Thu, 10 Jan 2008 11:57:33 -0800
Message-ID: <478678AD.1070006@intel.com>
References: <475F107A.8080201@intel.com> <47684AA9.9050409@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	NetDev <netdev@vger.kernel.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:23704 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754390AbYAJT6x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2008 14:58:53 -0500
In-Reply-To: <47684AA9.9050409@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
> Looks pretty decent.  Main comments (style mostly, driver operation path
> seems sound):

thanks again for the comments. I am about to send an updated patch just before my
vacation and before I do let me just quickly touch on your comments below:

> * kill the bitfields and unions [in descriptor structs].  they are not
> endian-safe as presented, generate poor code, and are otherwise
> undesirable.

that bitfield was unused and so I removed the code. I don't see any more bitfields
at all now in this driver.

> * the basic operations are too verbose:  E1000_READ_REG(hw, REGISTER) is
> far more readable as ER32(REGISTER), following the style of other
> drivers.  Furthermore, the "E1000_" prefix, in addition to being overly
> redundant (used in each register read/write), it is also incorrect,
> because this is not E1000...

partially I agree, and I refined the register writes to remove the need for the
"hw" part.

However the hardware *is* e1000, we ended up making a new driver since it just
does not make sense to add all of this infrastructure for older chipsets anymore.

renaming everything (from e1000_ to igb_) would just make life for us really hard
looking up historical diffs, history etc. and most importantly compare with
e1000/e1000e when we encounter an issue that might affect the other drivers. For
now it is easier to just leave these alone.

I however do not rule out that we change this at a later stage ...

> * in general, rename everything with "e1000_" prefix.  this will
> eliminate plenty of human confusion in the long run.

I'm doing this for all functions, which solves the namespace collisions. The
"e1000" specific static structs (which are the same in igb as they are in e1000,
e1000e) as well as the registers (ditto) I'll keep unchanged for now.

> * API:   unless you have chips in the lab that will require an API hook,
> don't create one.  For example, a direct call to
> e1000_acquire_nvm_82575() should replace all ->acquire_nvm() hooks....
> if there are no chips in pipeline GUARANTEED to have a different
> ->acquire_nvm() feature.

Noted

Note also that there are already many less hooks as there are in e1000e. We did
already make an effort to scrub as many as we can.


Cheers,

Auke

