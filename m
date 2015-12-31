From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] igb: When GbE link up, wait for Remote receiver status condition.
Date: Wed, 30 Dec 2015 20:42:10 -0800
Message-ID: <CAL3LdT5LOO1_919ZpWO-a=iMy-Omum-VDDi_XHSN9ZgtETGZPw@mail.gmail.com>
References: <1451477381-64480-1-git-send-email-t.ueba11@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Takuma Ueba <t.ueba11@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:33982 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753248AbbLaEmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 23:42:10 -0500
Received: by mail-ig0-f178.google.com with SMTP id ik10so35627913igb.1
        for <netdev@vger.kernel.org>; Wed, 30 Dec 2015 20:42:10 -0800 (PST)
In-Reply-To: <1451477381-64480-1-git-send-email-t.ueba11@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 30, 2015 at 4:09 AM, Takuma Ueba <t.ueba11@gmail.com> wrote:
> I210 device IPv6 autoconf test sometimes fails,
> because DAD NS for link-local is not transmitted.
> This packet is silently dropped.
> This problem is seen only GbE environment.
>
> igb_watchdog_task link up detection continues to the following process.
> The following cases are observed:
> 1.PHY 1000BASE-T Status Register Remote receiver status bit is NG.
> (NG status becomes OK after about 200 - 700ms)
> 2.In this case, the transfer packet is silently dropped.
>
> 1000BASE-T Status register
> [Expected]: 0x3800 or 0x7800
> [problem occurred]: 0x2800 or 0x6800
> Frequency of occurrence: approx 1/10 - 1/40 observed
>
> In order to avoid this problem,
> wait until 1000BASE-T Status register "Remote receiver status OK"
>
> After applying this patch, at least 400 runs succeed with no problems.
>
> Signed-off-by: Takuma Ueba <t.ueba11@gmail.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c | 20 ++++++++++++++++++++
>  1 file changed, 20 insertions(+)

Please send this to intel-wired-lan@lists.osuosl.org mailing list, or
at least CC the list since all Wired Ethernet Intel driver patches are
handled through that list.
