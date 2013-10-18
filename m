From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/9 RESENT] staging: r8188eu: Fix sparse warnings in
 ioctl_linux.c
Date: Fri, 18 Oct 2013 23:08:31 +0100
Message-ID: <1382134111.3381.25.camel@bwh-desktop.uk.level5networks.com>
References: <1382129563-8496-1-git-send-email-Larry.Finger@lwfinger.net>
	 <5261A967.9000909@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <gregkh@linuxfoundation.org>, <netdev@vger.kernel.org>,
	<devel@driverdev.osuosl.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:57297 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754406Ab3JRWIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 18:08:34 -0400
In-Reply-To: <5261A967.9000909@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-10-18 at 16:34 -0500, Larry Finger wrote:
> Sparse checking results in the following warnings:
> 
>    CHECK   drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
> drivers/staging/rtl8188eu/os_dep/ioctl_linux.c:3932:17: warning: cast removes 
> address space of expression
> drivers/staging/rtl8188eu/os_dep/ioctl_linux.c:3933:31: warning: incorrect type 
> in argument 1 (different address spaces)
[...]
> -		DBG_88E("[%s] extra = %s\n", __func__, (char *)wrqu->data.pointer);
> -	if (!memcmp(wrqu->data.pointer, "status", 6)) {
> +		DBG_88E("[%s] extra = %s\n", __func__, (__force char *)wrqu->data.pointer);
> +	if (!memcmp((__force const char *)wrqu->data.pointer, "status", 6)) {
[...]

This is hiding the problem, not fixing it.

This private interface needs to be removed anyway.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
