From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net-next 01/10] bnxt_en: Improve bnxt_vf_update_mac().
Date: Thu, 25 Feb 2016 08:57:01 -0800
Message-ID: <CACKFLi=ycecx03nPAUzVPG8-v8tvPEC5iXUtpwibVkAxhwdzMg@mail.gmail.com>
References: <1456388374-1440-1-git-send-email-michael.chan@broadcom.com>
	<1456388374-1440-2-git-send-email-michael.chan@broadcom.com>
	<20160225.113128.1989544272292631983.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:35934 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933122AbcBYQ5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 11:57:03 -0500
Received: by mail-oi0-f44.google.com with SMTP id w5so43639990oie.3
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 08:57:02 -0800 (PST)
In-Reply-To: <20160225.113128.1989544272292631983.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 25, 2016 at 8:31 AM, David Miller <davem@davemloft.net> wrote:
> From: Michael Chan <michael.chan@broadcom.com>
> Date: Thu, 25 Feb 2016 03:19:25 -0500
>
>> From: Jeffrey Huang <huangjw@broadcom.com>
>>
>> Allow the VF to setup its own MAC address if the PF has not administratively
>> set it for the VF.  If the perm_mac_address returned by firmware is all
>> zeros, that means the PF has not set up the MAC address for the VF and
>> we should store it.  This will allow the VF to change the MAC address using
>> ndo_set_mac_address() when it sees that the stored permanent MAC address
>> is all zeros.
>>
>> Signed-off-by: Jeffrey Huang <huangjw@broadcom.com>
>> Signed-off-by: Michael Chan <michael.chan@broadcom.com>
>
> What triggers that ->ndo_set_mac_address() call in the VF?

ip link set eth0 address ...

done on the VF.

>
> You cannot register an ethernet netdev with an invalid ethernet address,
> you must use a random one if you don't have a valid one available.

We are not registering an invalid MAC address.  We are just storing it in the
driver's VF data structure.  There are 2 cases:

1. VF comes up and the MAC address from firmware is 0.  The VF will
generate random MAC.  The stored MAC address in the VF datastructure is
0 so that ip set link eth0 address is allowed on the VF.

2. PF sets the MAC address for the VF using ip link set eth0 vf mac ....
The firmware will now provide the PF administered MAC address to the
VF and random MAC is no longer generated.  This valid MAC is now
stored and ip link set eth0 address ... on the VF is no longer allowed.

This patch is to make case 2 work properly.  I will change the commit
message to make it more clear and I will fix the parameter formatting
in the other patch.  Thanks.
