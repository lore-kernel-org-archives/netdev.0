From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: setsockopt()
Date: Mon, 7 Jul 2008 21:48:40 -0400
Message-ID: <20080708014840.GA25173@fieldses.org>
References: <20080707142408.43aa2a2e@extreme> <48728B09.1050801@citi.umich.edu> <48729DAD.8010400@hp.com> <20080707.160029.13296246.davem@davemloft.net> <4872A652.2050709@hp.com> <4872BF95.9030209@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	aglo@citi.umich.edu, shemminger@vyatta.com, rees@umich.edu
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:48602 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754844AbYGHBsl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jul 2008 21:48:41 -0400
Content-Disposition: inline
In-Reply-To: <4872BF95.9030209@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 07, 2008 at 06:15:01PM -0700, Rick Jones wrote:
> Rick Jones wrote:
>> David Miller wrote:
>>
>>> We need 2x, in order to have a full window during recovery.
>>>
>>> There was a measurement bug found a few months ago when the
>>> google folks were probing in this area, which was fixed
>>> by John Heffner.  Most of which had to deal with TSO subtleties.
>>>
>>> --------------------
>>> commit 246eb2af060fc32650f07203c02bdc0456ad76c7
>>> ...
>>> commit ce447eb91409225f8a488f6b7b2a1bdf7b2d884f
>>> ...
>> I'll try my tests again with newer kernels since I'm not 100% certain I 
>> was trying with those commits in place.
>
> Did those commits make it into 2.6.26-rc9?  (Gentle taps of clue-bat as  
> to how to use git to check commits in various trees would be welcome -  
> to say I am a git noob would be an understatement - the tree from which  
> that kernel was made was cloned from Linus' about 16:00 to 17:00 pacific  
> time)

"git describe --contains", will tell you the first tag git finds
containing the given commit:

	bfields@pickle:linux$ git describe --contains 246eb2af060
	v2.6.26-rc1~95^2~18
	bfields@pickle:linux$ git describe --contains ce447eb9140
	v2.6.26-rc1~95^2~19

So both were already in 2.6.25-rc1.

Or if you forget that, another trick is to note that git log A..B really
means "tell me all the commits contained in B but not in A".  So "git
log A..B" returns output if (and only if) B is not contained in A.  For
example, if "git log HEAD..246eb2af060" returns without any output, then
you know that 246eb2af060 is contained in the head of the currently
checked-out branch.

--b.
