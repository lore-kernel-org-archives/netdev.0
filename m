From: alexmcwhirter@triadic.us
Subject: Re: PROBLEM: network data corruption (bisected to e5a4b0bb803b)
Date: Wed, 27 Jul 2016 20:26:48 -0400
Message-ID: <8b3126f66186015956e0f8090fb70532@triadic.us>
References: <201607271032.u6RAWPcS008174@sdf.org>
 <4dbfebe8136bc963b5b51463d6887db4@triadic.us>
 <87c4ed555bcb4229f2334f6f2bb69bcb@triadic.us>
 <20160727.164543.1466564919313003461.davem@davemloft.net>
 <20160728003102.GS2356@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rlwinm@sdf.org,
	chunkeey@googlemail.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Al Viro <viro@ftp.linux.org.uk>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.tech.triadic.us ([98.102.61.98]:46355 "EHLO
	SMTP.Tech.Triadic.US" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758277AbcG1Ahf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 20:37:35 -0400
In-Reply-To: <20160728003102.GS2356@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016-07-27 20:31, Al Viro wrote:
> On Wed, Jul 27, 2016 at 04:45:43PM -0700, David Miller wrote:
> 
>> > I highly expect both my issue and OP's issue to revolve not around
>> > commit e5a4b0bb803b specifically, but around other code that no longer
>> > behaves as expected because of it.
>> 
>> Indeed, and that fault address rounding bug occurs two other times
>> in arch/sparc/lib/user_fixup.c
>> 
>> The mentioned patchwork patch should fix the bug and I'll get that
>> into my sparc tree, merged, and queued up for -stable ASAP.
> 
> Plausible for sparc, but I don't see similar __copy_to_user_inatomic()
> bugs in case of x86_64...

I'm going to go ahead and say this is where my issue and the op's issue 
begin to branch apart from one another. He's seeing this on all incoming 
data, whereas i am only seeing it on ssl data and not on sun4v.

At this point i would say data from my issue is only going to cloud this 
issue as they seem to be two completely different issues revolving 
around the same commit. If i come across any relevant data for x86_64 
ill be sure to post it if this isn't resolved by then, but for now i'm 
going to refrain from submitting anything sparc related.
