From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] hostap_plx: fix CIS verification
Date: Tue, 24 Oct 2006 20:37:07 -0400
Message-ID: <20061025003707.GB7340@tuxdriver.com>
References: <1161382815.5803.2.camel@dv> <20061021011943.GC6140@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:5641 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1161306AbWJYAhd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2006 20:37:33 -0400
To: Pavel Roskin <proski@gnu.org>, netdev@vger.kernel.org,
	hostap@shmoo.com
Content-Disposition: inline
In-Reply-To: <20061021011943.GC6140@jm.kir.nu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 20, 2006 at 06:19:43PM -0700, Jouni Malinen wrote:
> On Fri, Oct 20, 2006 at 06:20:15PM -0400, Pavel Roskin wrote:
> 
> > The record length for numerical manufacturer ID should be at least 4
> > bytes (two 16-bit words).  The code required 5 bytes, which would break
> > for most (if not all) cards.  Reported by ph35sm@free.fr
> 
> >  		case CISTPL_MANFID:
> > -			if (cis[pos + 1] < 5)
> > +			if (cis[pos + 1] < 4)
> 
> Hmm.. Interesting. I think this was changed from 4 to 5 due to a
> potential buffer overflow as reported by Coverity tools.. In addition, I
> think that I spent long time trying to understand why it could be a
> buffer overflow and since it was changed, likely finally figured out an
> example case.. Alas, I don't remember what exactly this was anymore.
> 
> It looks like the comparison of the length field to be <5 was incorrect,
> but in order to avoid re-introducing any potential buffer overflows,
> that condition could be extended to verify that pos is small enough..
> Something like (cis[pos + 1] < 4 && pos + 5 < CIS_MAX_LEN) could be a
> better fix here. I don't have easy access to PLX cards anymore, so this
> is untested and I'm too lazy to copy this function into a separate
> program to run it against CIS dumps.

Pavel,

Will you be refactoring this patch?  Or do you disagree with Jouni's
assessment?

Thanks,

John
