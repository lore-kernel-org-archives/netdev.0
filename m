From: Kevin Wallace <kevin@pentabarf.net>
Subject: Re: [PATCH] macvlan: Support creating macvtaps from macvlans
Date: Tue, 3 Dec 2013 01:58:37 -0800
Message-ID: <CAEQCv+aM6_SYR1-igsHXmBgxOMsQwBAFNrYe6_VxMEEH62xg3A@mail.gmail.com>
References: <1386043991-4372-1-git-send-email-kevin@pentabarf.net> <20131203082450.GA17839@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f45.google.com ([209.85.216.45]:62838 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752301Ab3LCJ66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 04:58:58 -0500
Received: by mail-qa0-f45.google.com with SMTP id o15so5414864qap.11
        for <netdev@vger.kernel.org>; Tue, 03 Dec 2013 01:58:57 -0800 (PST)
In-Reply-To: <20131203082450.GA17839@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Good call; I didn't see those.  I'll grab a more recent snapshot that
includes those helpers, and send out a v2 once I've tested.

Thanks!

Kevin

On Tue, Dec 3, 2013 at 12:24 AM, Michal Kubecek <mkubecek@suse.cz> wrote:
> On Mon, Dec 02, 2013 at 08:13:11PM -0800, Kevin Wallace wrote:
>> -     /* When creating macvlans on top of other macvlans - use
>> +     /* When creating macvlans or macvtaps on top of other macvlans - use
>>        * the real device as the lowerdev.
>>        */
>> -     if (lowerdev->rtnl_link_ops == dev->rtnl_link_ops) {
>> +     if (lowerdev->rtnl_link_ops == &macvlan_link_ops) {
>>               struct macvlan_dev *lowervlan = netdev_priv(lowerdev);
>>               lowerdev = lowervlan->lowerdev;
>>       }
>
> Perhaps we could use the helpers:
>
>         if (netif_is_macvlan(lowerdev))
>                 lowerdev = macvlan_dev_real_dev(lowerdev);
>
> to show more clearly what we are doing.
>
>                                                         Michal Kubecek
>
