From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: [PATCH] hostap_plx: fix CIS verification
Date: Fri, 20 Oct 2006 18:19:43 -0700
Message-ID: <20061021011943.GC6140@jm.kir.nu>
References: <1161382815.5803.2.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, hostap@shmoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.genealogia.fi ([194.100.116.229]:19614 "EHLO
	mail2.genealogia.fi") by vger.kernel.org with ESMTP
	id S2992770AbWJUBVN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Oct 2006 21:21:13 -0400
To: Pavel Roskin <proski@gnu.org>
Content-Disposition: inline
In-Reply-To: <1161382815.5803.2.camel@dv>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 20, 2006 at 06:20:15PM -0400, Pavel Roskin wrote:

> The record length for numerical manufacturer ID should be at least 4
> bytes (two 16-bit words).  The code required 5 bytes, which would break
> for most (if not all) cards.  Reported by ph35sm@free.fr

>  		case CISTPL_MANFID:
> -			if (cis[pos + 1] < 5)
> +			if (cis[pos + 1] < 4)

Hmm.. Interesting. I think this was changed from 4 to 5 due to a
potential buffer overflow as reported by Coverity tools.. In addition, I
think that I spent long time trying to understand why it could be a
buffer overflow and since it was changed, likely finally figured out an
example case.. Alas, I don't remember what exactly this was anymore.

It looks like the comparison of the length field to be <5 was incorrect,
but in order to avoid re-introducing any potential buffer overflows,
that condition could be extended to verify that pos is small enough..
Something like (cis[pos + 1] < 4 && pos + 5 < CIS_MAX_LEN) could be a
better fix here. I don't have easy access to PLX cards anymore, so this
is untested and I'm too lazy to copy this function into a separate
program to run it against CIS dumps.

-- 
Jouni Malinen                                            PGP id EFC895FA
