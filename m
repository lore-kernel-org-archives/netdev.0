From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 3/9 RESENT] staging: r8188eu: Fix sparse warnings in ioctl_linux.c
Date: Fri, 18 Oct 2013 20:45:28 -0500
Message-ID: <5261E438.2030508@lwfinger.net>
References: <1382129563-8496-1-git-send-email-Larry.Finger@lwfinger.net>	 <5261A967.9000909@lwfinger.net> <1382134111.3381.25.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	devel@driverdev.osuosl.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f48.google.com ([209.85.219.48]:57222 "EHLO
	mail-oa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755078Ab3JSBpa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 21:45:30 -0400
Received: by mail-oa0-f48.google.com with SMTP id m17so3245579oag.7
        for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 18:45:29 -0700 (PDT)
In-Reply-To: <1382134111.3381.25.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/18/2013 05:08 PM, Ben Hutchings wrote:
> On Fri, 2013-10-18 at 16:34 -0500, Larry Finger wrote:
>> Sparse checking results in the following warnings:
>>
>>     CHECK   drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
>> drivers/staging/rtl8188eu/os_dep/ioctl_linux.c:3932:17: warning: cast removes
>> address space of expression
>> drivers/staging/rtl8188eu/os_dep/ioctl_linux.c:3933:31: warning: incorrect type
>> in argument 1 (different address spaces)
> [...]
>> -		DBG_88E("[%s] extra = %s\n", __func__, (char *)wrqu->data.pointer);
>> -	if (!memcmp(wrqu->data.pointer, "status", 6)) {
>> +		DBG_88E("[%s] extra = %s\n", __func__, (__force char *)wrqu->data.pointer);
>> +	if (!memcmp((__force const char *)wrqu->data.pointer, "status", 6)) {
> [...]
>
> This is hiding the problem, not fixing it.
>
> This private interface needs to be removed anyway.

I agree, but that is not likely to happen soon. I will just leave this set of 
Sparse warnings alone.

Larry
