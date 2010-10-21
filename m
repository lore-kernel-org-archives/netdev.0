From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCHv2] vmxnet3: remove set_flag_le{16,64} helpers
Date: Thu, 21 Oct 2010 08:24:02 -0700
Message-ID: <AANLkTiniqn3fzw+XBL6_xBahSHckuucth37tRsdrWrQ7@mail.gmail.com>
References: <1287642721-5997-1-git-send-email-harvey.harrison@gmail.com>
	<20101021.035741.68130271.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: sbhatewara@vmware.com, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:50154 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752696Ab0JUPYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 11:24:05 -0400
Received: by gwj21 with SMTP id 21so168067gwj.19
        for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 08:24:03 -0700 (PDT)
In-Reply-To: <20101021.035741.68130271.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 21, 2010 at 3:57 AM, David Miller <davem@davemloft.net> wrote:
> From: Harvey Harrison <harvey.harrison@gmail.com>
> Date: Wed, 20 Oct 2010 23:32:01 -0700
>
>> It's easier to just annotate the constants as little endian types and set/clear
>> the flags directly.
>>
>> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
>> ---i
>> Sorry, missed a git add and left a line out of the previous patch.
>
> Could you please rebase this against net-next-2.6 since I've
> applied Stephen Hemminger's patch.
>

Sure, will do, I actually think there's an endian bug or two in this
driver that sparse catches
once you suppress the spew coming out of the
VMXNET_{READ,WRITE}_BAR{0,1} macros.

Why is this driver byteswapping everything to little-endian before
sticking it into writel()?  Isn't
writel() defined to write out in little-endian as per PCI?  Similarly
for swapping whatever it reads
in from readl()?

What am I missing?

Harevy
