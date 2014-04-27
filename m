From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 9/9 v2] net: Add sysctl to trust checksum_complete
Date: Sat, 26 Apr 2014 19:31:35 -0700
Message-ID: <20140426193135.7390d306@samsung-9>
References: <alpine.DEB.2.02.1404261402390.27405@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f45.google.com ([209.85.216.45]:65009 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752165AbaD0Cbk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2014 22:31:40 -0400
Received: by mail-qa0-f45.google.com with SMTP id cm18so5102951qab.32
        for <netdev@vger.kernel.org>; Sat, 26 Apr 2014 19:31:39 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1404261402390.27405@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 26 Apr 2014 14:26:35 -0700 (PDT)
Tom Herbert <therbert@google.com> wrote:

> Currently if a device provides CHECKSUM_COMPLETE but the checksum
> is calculated to be invalid we recompute the checksum and try
> again in software. On the other hand, if device returns
> CHECKSUM_UNNECESSARY we implicitly trust it and don't verify what it
> did. This seems backwards!
> 
> Add a sysctl to trust the device and report an invalid checksum when
> CHECKSUM_COMPLETE shows it is incorrect. sysctl defaults to enabled.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---

NO. Make one choice and do it consistently.

Papering over driver bugs or design confusion with a sysctl is not a
reasonable choice.

If some device (or code path) has invalid checksum logic, it should
be reported once and go ahead and fix it in software. The problem with
CHECKSUM_UNNECESSARY is that there is no way to check that the device
is broken without computing the checksum (catch-22).
