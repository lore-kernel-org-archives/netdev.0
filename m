From: =?ISO-8859-1?Q?Svenning_S=F8rensen?= <sss@secomea.com>
Subject: Re: via-rhine: Problem with lost link after a while
Date: Wed, 11 Apr 2012 11:49:51 +0200
Message-ID: <4F8553BF.6030303@secomea.com>
References: <CACPM=kWa=UWuCMaYAtVMGJ7pzCy-PfyNRWBSuJnTZGtssU0W6g@mail.gmail.com> <20120410204249.GA26627@electric-eye.fr.zoreil.com> <CACPM=kWsU8QZOHqwEThTQCuSSvaTDoxO1d17EyoW=+kx8QG3vw@mail.gmail.com> <20120410225534.GA28480@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bjarke Istrup Pedersen <gurligebis@gentoo.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Andreas Mohr <andi@lisas.de>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.secomea.com ([130.226.208.142]:1117 "EHLO mail.secomea.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752846Ab2DKJ6e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2012 05:58:34 -0400
In-Reply-To: <20120410225534.GA28480@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 11-04-2012 00:55, Francois Romieu wrote:
> Bjarke Istrup Pedersen<gurligebis@gentoo.org>  :
>
> [...]
>> Great, I'll try a 3.4-rc2 kernel, and see how it runs.
>>
>> The thread I was talking about earlier is here:
>> http://lists.soekris.com/pipermail/soekris-tech/2012-April/018318.html
>> Is there any of the changes he has there, that makes sense in the new
>> driver you wrote ?
> (I did not write a new driver)
>
> Regarding Svenning's patch:
> - the wmb in alloc_rbufs may help rhine_reset_task().
> - one should probably add one in rhine_rx() as well.
> - rhine_start_tx() is supposed to stop queueing when there is no room left.
>    I'm curious to know if the "Tx descriptor busy" test triggered.
> - the rmb() in rhine_tx() will not make a difference for a single core but
>    it's a good reminder that I should not have forgotten to propagate the
>    xmit / Tx completion fix back from the r8169 driver to the via-rhine one
>    (sigh)
>
> mmiowb is probably missing. I doubt it hits hard right now.
>
> I have not checked if MMIO flushes are missing. Actually I need some sleep.
>

Regarding the "Tx descriptor busy" test: no, I didn't see it trigger, I 
just put it there just in case because I suspected there could be a race 
due to the lock-free tx path.
But I'm glad if you're confident that it can't happen :)

Svenning
