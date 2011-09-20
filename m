From: Henry Wong <v4l@stuffedcow.net>
Subject: Re: ppp_generic: fix multilink fragment MTU calculation (again)
Date: Tue, 20 Sep 2011 15:54:32 -0400
Message-ID: <4E78EF78.7060106@stuffedcow.net>
References: <4E7681BD.2040902@stuffedcow.net> <20110920.152128.1875285861948423018.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.stuffedcow.net ([206.248.137.124]:40693 "EHLO
	mail.stuffedcow.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314Ab1ITTx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2011 15:53:57 -0400
In-Reply-To: <20110920.152128.1875285861948423018.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/20/2011 3:21 PM, David Miller wrote:
> From: Henry Wong<v4l@stuffedcow.net>
> Date: Sun, 18 Sep 2011 19:41:49 -0400
>
>> When using MLPPP, the maximum size of a fragment is incorrectly
>> calculated with an offset of -2.
>> This patch reverses the changes in the patch found here:
>> http://marc.info/?l=linux-netdev&m=123541324010539&w=2
>>
>> The value of hdrlen includes the size of both the 2-byte PPP protocol
>> field and the 2- or 4-byte multilink header (2+4=6 for long sequence
>> numbers, 2+2=4 for short sequence numbers). Section 2 of RFC1661 says
>> that the MRU that is negotiated (i.e., the MTU of the sending system)
>> includes only the PPP payload but not the protocol field, thus the
>> correct MTU should be the link's MTU minus the multilink header (mtu -
>> (hdrlen-2)).
>>
>> The incorrect calculation causes Linux to fragment packets to a size
>> two bytes smaller than the allowed MTU. While not technically illegal,
>> this behaviour confounds MRU-tuning to avoid PPP-layer fragmentation.
>>
>> Signed-off-by: Henry Wong<henry@stuffedcow.net>
> Applied, thanks.
>
> There were several cases of trailing whitespace in your patch which I
> needed to fix up.  Please don't be so careless in the future.
>
> Thanks.
>

Thanks.

Out of curiosity, were the trailing whitespaces on Lines 10 and 11? Or 
was there a problem with file attachments that cause some whitespace I 
don't see? I'll be more careful next time :)
