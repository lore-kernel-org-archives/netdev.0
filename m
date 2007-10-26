From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 1] net: fix and typo's
Date: Fri, 26 Oct 2007 11:25:58 -0700
Message-ID: <20071026112558.45fad718@freepuppy.rosehill>
References: <47221EBE.3070109@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Roel Kluin <12o3l@tiscali.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:51188 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757908AbXJZS1A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 14:27:00 -0400
In-Reply-To: <47221EBE.3070109@tiscali.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 26 Oct 2007 19:07:10 +0200
Roel Kluin <12o3l@tiscali.nl> wrote:

> A few patches with changes to net code. I have sent these to the lkml
> previously, but they were not yet merged. I am fairly new to kernel 
> programming, so it is possible that I make some mistakes. I'll explain my
> rationale, please nack if incorrect, an additional bit of explanation is
> appreciated even more.
> 
> The condition '!x & y,' does make little sense: the '!' has a higher
> priority than '&'. It behaves therefore like '!x && y'. In the case 
> bitanding flags, however, '!(x & y)' appears to be desired.
> 
> Warning: the change of '!x & y,' to '!(x & y)' may change behavior. if
> not desired, I propose changing this to '!x && y', to make it explicitly
> clear.
> 
> These '&' typo's can be spotted with:
> a="A-Za-z0-9_"
> git-grep "\![^$a()]*[$a]\+\([$a.]*\|->\)*\(\[[$a.]*\]\)\?[ \W]*&[^&]\+"
> 
> --
>         Fix priority mistakes similar to '!x & y'
>     
>         Signed-off-by: Roel Kluin <12o3l@tiscali.nl>

I agree these look good, but maybe they should be broken into separate patches to
make bisection of any induced regressions easier.

Stephen Hemminger <shemminger@linux-foundation.org>
