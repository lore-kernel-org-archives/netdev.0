From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] packet: packet_getname_spkt: make sure string is
 always 0-terminated
Date: Thu, 13 Jun 2013 22:02:03 +0200
Message-ID: <51BA253B.4010701@redhat.com>
References: <1371045747-15203-1-git-send-email-dborkman@redhat.com>  <20130613.013859.1357765580190105873.davem@davemloft.net> <1371143153.2246.10.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23489 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756060Ab3FMUCL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jun 2013 16:02:11 -0400
In-Reply-To: <1371143153.2246.10.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/13/2013 07:05 PM, Ben Hutchings wrote:
> On Thu, 2013-06-13 at 01:38 -0700, David Miller wrote:
>> From: Daniel Borkmann <dborkman@redhat.com>
>> Date: Wed, 12 Jun 2013 16:02:27 +0200
>>
>>> uaddr->sa_data is exactly of size 14, which is hard-coded here and
>>> passed as a size argument to strncpy(). A device name can be of size
>>> IFNAMSIZ (== 16), meaning we might leave the destination string
>>> unterminated. Thus, use strlcpy() and also sizeof() while we're
>>> at it. We need to memset the data area beforehand, since strlcpy
>>> does not padd the remaining buffer with zeroes for user space, so
>>> that we do not possibly leak anything.
>>>
>>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>>
>> Applied, and queued up for -stable, thanks.
>
> I don't think this should be applied anywhere.  Dropping support for
> 14-character device names is a regression.

I don't think this would be reasonable, because it can pose a security
risk for user space. In all other cases, we null-terminate the string, so
people might trust what they get from the kernel and expect this to happen
except in this particular border case.

I agree that this is pretty broken, but I would say it's a bug in the kernel
that can potentially cause user space to crash (or worse) that is making use
of this. There also seems to be no man page documentation about it, only that
spkt is heavily deprecated from what I read, and shouldn't be used nowadays.
