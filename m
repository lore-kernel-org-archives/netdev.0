From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH][CAN]: Fix copy_from_user() results interpretation.
Date: Sat, 26 Apr 2008 15:04:30 +0200
Message-ID: <4813285E.1000407@grandegger.com>
References: <4811E915.80303@volkswagen.de>	<4812C973.5000504@grandegger.com>	<20080426064007.GA20558@uranus.ravnborg.org> <20080426.000302.177643527.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: sam@ravnborg.org, oliver.hartkopp@volkswagen.de,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	urs.thuermann@volkswagen.de, xemul@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:40607 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751656AbYDZNEe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2008 09:04:34 -0400
In-Reply-To: <20080426.000302.177643527.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Sam Ravnborg <sam@ravnborg.org>
> Date: Sat, 26 Apr 2008 08:40:07 +0200
> 
>> On Sat, Apr 26, 2008 at 08:19:31AM +0200, Wolfgang Grandegger wrote:
>>> What about removing the assignment "err =" in that case.
>> Preferred.
>>
>> See sample patch below (made on top of -linus
>> so it does likely not apply but made it only to
>> see the difference anyway).
> 
> I want to make one comment, directed at Wolfgang.
> 
> You are absolutely wrong, Wolfgang, in saying that Pavel's
> original patch isn't easier to review than just changing
> this code to go:
> 
> 	if (copy_*_user())
> 		return -EFAULT;
> 
> In fact, recoding things like this is an immense extra hardship on a
> reviewer.  I'll explain why.
> 
> If I see a patch that changes:
> 
> 	err = SOMETHING;
> 	break;
> 
> into:
> 
> 	err = SOMETHING_ELSE;
> 	break;
> 
> I know, WITH JUST READING THE PATCH, exactly what the side effects of
> this change are.
> 
> I DO NOT need to bring the code into my editor and validate side
> effects to the surrounding code.
> 
> I know that the assignment to 'err' is being changed, and that's it.
> 
> Whereas if you change:
> 
> 	err = SOMETHING;
> 	break;
> 
> into:
> 
> 	if (SOMETHING)
> 		return -SOME_ERROR;
> 	break;
> 
> I now have to bring the code into an editor and make sure that the
> control flow change doesn't break things.
> 
> For example, maybe the exit of the switch statement was important, to
> make sure cleanup code runs at the end of the function to release
> locks, free allocated memory, etc.
> 
> With Pavel's patch it is not necessary to make such validations so
> it's INFINITELY easier to validate.

OK, I see, if you have to review a lot of patches, it does matter, indeed.

Wolfgang.

