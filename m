From: roopa <roopa@cumulusnetworks.com>
Subject: Re: mpls's find_outdev()
Date: Thu, 07 Apr 2016 19:50:27 -0700
Message-ID: <57071C73.5080206@cumulusnetworks.com>
References: <20160407.214109.32624032556886158.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36697 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752302AbcDHCua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 22:50:30 -0400
Received: by mail-pa0-f51.google.com with SMTP id bx7so49995403pad.3
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 19:50:29 -0700 (PDT)
In-Reply-To: <20160407.214109.32624032556886158.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/7/16, 6:41 PM, David Miller wrote:
> While auditing something unrelated, I noticed that this function seems
> to potentially dev_put() on an error pointer.
>
> I guess the problem comes from the fact that there are two methods
> by which the device pointer is obtained.
>
> First, inet{,6}_fib_lookup_dev() which uses error pointers.
>
> Second, dev_get_by_index() which returns a valid device or NULL,
> and therefore does not use error pointers.
>
> If inet{,6}_fib_lookup_dev() returns an error pointer, the !dev check
> will not pass and dev_put() will operate on an error pointer and
> crash.
>
> If you agree with my analysis, could you please cook up and test a
> fix?
>
> Thank you!
certainly!. I see it. Thanks for catching it.
I will test and post a fix in a few hours.
