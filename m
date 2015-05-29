From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH net-next 02/14] sfc: Add sysfs entry for flags (link control
 and primary)
Date: Fri, 29 May 2015 14:09:01 +0100
Message-ID: <556864ED.1080408@solarflare.com>
References: <55683895.2090408@solarflare.com> <556838ED.8020407@solarflare.com> <063D6719AE5E284EB5DD2968C1650D6D1CB42986@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'Shradha Shah' <sshah@solarflare.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-net-drivers@solarflare.com" <linux-net-drivers@solarflare.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:31938 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753782AbbE2NJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 09:09:13 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB42986@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29/05/15 11:48, David Laight wrote:
> From: Shradha Shah
>> Sent: 29 May 2015 11:01
>> On  every adapter there will be one primary PF per adaptor and
>> one link control PF per port.
> ...
>> +	return sprintf(buf, "%d\n",
>> +		       ((efx->mcdi->fn_flags) &
>> +			(1 << MC_CMD_DRV_ATTACH_EXT_OUT_FLAG_LINKCTRL))
>> +		       ? 1 : 0);
> Horrid expression.
> Why not:
> 	(efx->mcdi->fn_flags >> MC_CMD_DRV_ATTACH_EXT_OUT_FLAG_LINKCTRL) & 1
I think the idea is that this is more explicit about what it's doing.
It's a toss-up which is more readable / idiomatic; I prefer the OP version.
(They probably compile to the same thing, though I haven't checked.)
> using sprintf() is also excessive. Maybe:
> 	*buf = '0' + (expression);
> 	return 1;
That loses the '\n'; it's annoying when you cat a file and it doesn't end in a '\n', because it gloms onto your shell prompt.
sprintf isn't really that expensive, this isn't likely to be called very frequently.
> You may also need to check for buffer overrun.
In fact Documentation/filesystems/sysfs.txt says that "show() should always use scnprintf()" and that "The buffer will always be PAGE_SIZE bytes in length."
So if we want to be consistent, it should be

	return scnprintf(buf, PAGE_SIZE, "%d\n", expression);

although it'd be rather surprising if either 0\n or 1\n were ever too big for PAGE_SIZE :grin:.
