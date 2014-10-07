From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH iproute2 1/5] iplink: Fix setting of -1 as ifindex
Date: Mon, 6 Oct 2014 17:42:11 -0700
Message-ID: <CAHA+R7N7_Aim_dvs2mdGaPWk59qYbuafzW8WUd2PRLT=Yc7K8g@mail.gmail.com>
References: <1412351718-22921-1-git-send-email-therbert@google.com>
	<1412351718-22921-2-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:59195 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbaJGAmN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 20:42:13 -0400
Received: by mail-la0-f51.google.com with SMTP id ge10so5350671lab.38
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 17:42:11 -0700 (PDT)
In-Reply-To: <1412351718-22921-2-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 3, 2014 at 8:55 AM, Tom Herbert <therbert@google.com> wrote:
> Commit 3c682146aeff157ec3540 ("iplink: forbid negative ifindex and
> modifying ifindex") initializes index to -1 in iplink_modify. When
> creating a link, req.i.ifi_index is then set to -1 if the link option is
> not used. In the kernel this is then used to set dev->ifindex. For
> dev->ifindex, zero is considered to be unset and -1 is treated as
> a set index, so when a second tunnel is create the new device conflicts
> with the old one (both have ifindex of -1) so -EBUSY is returned.
>
> This patch set zero in req.i.ifi_index is index is unset (still -1).


There was a patch before yours:
https://patchwork.ozlabs.org/patch/395404/
