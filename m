From: Mark Einon <mark.einon@gmail.com>
Subject: Re: [PATCH] ethtool: Add version check for et131x regs
Date: Tue, 22 Jan 2013 21:03:26 +0000
Message-ID: <CANK3SE1EQAtzTj7Z9HEQmX49u8VaaUwJ--YtGaEt+Oi_KdE+fg@mail.gmail.com>
References: <1357379851-5298-1-git-send-email-mark.einon@gmail.com> <1358887479.2892.22.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:52466 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751789Ab3AVVDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 16:03:42 -0500
Received: by mail-ie0-f173.google.com with SMTP id e13so12500032iej.32
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 13:03:41 -0800 (PST)
In-Reply-To: <1358887479.2892.22.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22 January 2013 20:44, Ben Hutchings <bhutchings@solarflare.com> wrote:
> On Sat, 2013-01-05 at 09:57 +0000, Mark Einon wrote:
>> Added a version check for the et131x reg dump, in case the dump format
>> needs to be changed later.
>>
>> Signed-off-by: Mark Einon <mark.einon@gmail.com>
>> ---
>>  et131x.c |    4 ++++
>>  1 file changed, 4 insertions(+)
>>
>> diff --git a/et131x.c b/et131x.c
>> index b36c184..8cdbec0 100644
>> --- a/et131x.c
>> +++ b/et131x.c
>> @@ -4,8 +4,12 @@
>>
>>  int et131x_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
>>  {
>> +     u8 version = (u8)(regs->version >> 24);
>>       u32 *reg = (u32 *)regs->data;
>>
>> +     if(version != 1)
>
> Needs a space before the open-parentheis.
>
> Ben.

You're right - I cut and pasted the code from another file without
checking. I'll send a separate patch for fixing them, if you want this
patch re-submitted as well, then just let me know.

cheers,

Mark

>
>> +             return -1;
>> +
>>       fprintf(stdout, "PHY Registers\n");
>>       fprintf(stdout, "0x0, Basic Control Reg          = 0x%04X\n", *reg++);
>>       fprintf(stdout, "0x1, Basic Status Reg           = 0x%04X\n", *reg++);
>
> --
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
