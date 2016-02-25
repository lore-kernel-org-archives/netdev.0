From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net-next 01/10] bnxt_en: Improve bnxt_vf_update_mac().
Date: Thu, 25 Feb 2016 09:15:39 -0800
Message-ID: <CACKFLik3f0ca4cnzMK1-H_qjF92GjA43cV-8ZBb018na97jZhA@mail.gmail.com>
References: <1456388374-1440-2-git-send-email-michael.chan@broadcom.com>
	<20160225.113128.1989544272292631983.davem@davemloft.net>
	<CACKFLi=ycecx03nPAUzVPG8-v8tvPEC5iXUtpwibVkAxhwdzMg@mail.gmail.com>
	<20160225.120921.2096022701010736406.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:35270 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758976AbcBYRPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 12:15:40 -0500
Received: by mail-oi0-f43.google.com with SMTP id x21so44151450oix.2
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 09:15:40 -0800 (PST)
In-Reply-To: <20160225.120921.2096022701010736406.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 25, 2016 at 9:09 AM, David Miller <davem@davemloft.net> wrote:
> From: Michael Chan <michael.chan@broadcom.com>
> Date: Thu, 25 Feb 2016 08:57:01 -0800
>
>> We are not registering an invalid MAC address.  We are just storing it in the
>> driver's VF data structure.  There are 2 cases:
>>
>> 1. VF comes up and the MAC address from firmware is 0.  The VF will
>> generate random MAC.  The stored MAC address in the VF datastructure is
>> 0 so that ip set link eth0 address is allowed on the VF.
>
> Who looks at this 0 MAC address in the "VF datastructure", the driver?

the VF driver.

>
> Why does there need to be a 0 MAC address there to allow
> ->ndo_set_mac_address() to succeed on the VF at all?

0 means that the PF has not set it.  If the PF had set it, the datastructure
would contain the MAC address set by the PF.  The idea is that if the
PF has administered a MAC address, we won't allow the VF to change
it using ndo.

>
> This MAC address management between VFs and PFs looks unnecessarily
> convoluted and complicated.  I'd hate to have to actually be a user
> configuring this stuff.
>

I agree it is complicated.  The default, if nobody does anything, is random
MAC.  But random MAC has disadvantages, so we allow some options
for the PF or VF users to change it.
