From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: 3.2.8/amd64 full interrupt hangs and deadlocks under big network
 copies (page allocation failure)
Date: Mon, 09 Apr 2012 13:58:55 -0500
Message-ID: <4F83316F.20504@lwfinger.net>
References: <20120409172051.GR32290@merlins.org> <20120409.141241.1216091936509309354.davem@davemloft.net> <20120409183632.GO29342@merlins.org> <20120409.143710.879746943062854492.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: marc@merlins.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:65378 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757498Ab2DIS7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2012 14:59:00 -0400
In-Reply-To: <20120409.143710.879746943062854492.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/09/2012 01:37 PM, David Miller wrote:
> From: Marc MERLIN<marc@merlins.org>
> Date: Mon, 9 Apr 2012 11:36:32 -0700
>
>> On Mon, Apr 09, 2012 at 02:12:41PM -0400, David Miller wrote:
>>> From: Marc MERLIN<marc@merlins.org>
>>> Date: Mon, 9 Apr 2012 10:20:51 -0700
>>>
>>>> Any idea what's going on, what bucket of RAM is an issue for the driver
>>>> (total RAM is more than plenty), and where I should go from there?
>>>
>>> The wireless layer is allocating high-order pages, so it's
>>> not the amount of ram, it's the fragmentation of it leading
>>> to a lack of those high-order pages.
>>
>> I figured it was something of the sort, thanks for the professional
>> confirmation :)
>>
>> What's my next step, file a bug with a specific team?
>
> Wait patiently for a wireless developer to look into your bug.

As it happens with both iwlwifi and e1000e, it seems to be a problem further up 
the food chain.

I don't know much about iwlwifi, but loading it with the module parameter 
"amsdu_size_8K=0" seems to select 4K rather than 8K buffers. That will hurt 
performance, but it should fix the memory fragmentation. There have also been 
some problems with aggregation that are fixed by setting the option "11n_disable=3".

Larry
