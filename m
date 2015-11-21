From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net] vrf: fix double free and memory corruption on
 register_netdevice failure
Date: Sat, 21 Nov 2015 15:55:36 -0700
Message-ID: <5650F668.8020502@cumulusnetworks.com>
References: <1448131579-20525-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shm@cumulusnetworks.com, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:35987 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891AbbKUWzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2015 17:55:40 -0500
Received: by igcph11 with SMTP id ph11so31913968igc.1
        for <netdev@vger.kernel.org>; Sat, 21 Nov 2015 14:55:39 -0800 (PST)
In-Reply-To: <1448131579-20525-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/21/15 11:46 AM, Nikolay Aleksandrov wrote:
> From: Nikolay Aleksandrov<nikolay@cumulusnetworks.com>
>
> When vrf's ->newlink is called, if register_netdevice() fails then it
> does free_netdev(), but that's also done by rtnl_newlink() so a second
> free happens and memory gets corrupted, to reproduce execute the
> following line a couple of times (1 - 5 usually is enough):
> $ for i in `seq 1 5`; do ip link add vrf: type vrf table 1; done;
> This works because we fail in register_netdevice() because of the wrong
> name "vrf:".

Acked-by: David Ahern <dsa@cumulusnetworks.com>

Thanks, Nik.
