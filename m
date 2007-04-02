From: Andi Kleen <andi@firstfloor.org>
Subject: Re: NIC data corruption
Date: Mon, 2 Apr 2007 20:07:17 +0200
Message-ID: <20070402180717.GA32435@one.firstfloor.org>
References: <20070401012736.GT15189@vitelus.com> <20070401030315.GA24080@jim.sh> <20070401043905.GV15189@vitelus.com> <p737iswqjq4.fsf@bingen.suse.de> <46114158.2030007@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Aaron Lehmann <aaronl@vitelus.com>, Jim Paris <jim@jtan.com>,
	netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:37707 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965621AbXDBSHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2007 14:07:23 -0400
Content-Disposition: inline
In-Reply-To: <46114158.2030007@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 02, 2007 at 10:46:00AM -0700, Rick Jones wrote:
> I changed the title to be more accurate, and culled the distribution to 
> individuals and netdev
> 
> The mention of trying to turn-off CKO and see if the data corruption 
> goes away leads me to ask a possibly "delicate" question:
> 
>   Should "Linux" only enable CKO on those NICs certified to have
>   ECC/parity throughout their _entire_ data path?

Even with reliable software checksumming you can have quite a lot of undetected
errors (there was a interesting study about this some years ago). 
If you really care about your data you should use SSL or some
other protocol with strong checksums.

That said it would probably make quite a lot of people unhappy
because it would make their NICs much slower and the occasional
bit error that is missed by the NIC is likely not a big issue for them.

What might be a good idea would to have some optional knob 
somewhere that allows to disable hardware checksumming for NICs
that are not trusted this way. But then someone would need to 
do the necessary research for the hundreds of NICs Linux support

Just providing a general global "disable hardware checksumming"
knob for the paranoid would be much easier. I guess that would
be a good idea.

-Andi

