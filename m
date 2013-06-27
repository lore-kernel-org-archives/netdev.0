From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] net: fec: reset rx mode when do suspend/resume or link
 status change
Date: Thu, 27 Jun 2013 10:21:14 -0300
Message-ID: <CAOMZO5DJ0hfXEdXK8etztoW0QorvCkX1j48EQ478+6O0tKWURA@mail.gmail.com>
References: <1372309759-5067-1-git-send-email-B38611@freescale.com>
	<20130627131503.GC2695@S2101-09.ap.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Fugang Duan <B38611@freescale.com>, b20596@freescale.com,
	davem@davemloft.net, netdev@vger.kernel.org,
	bhutchings@solarflare.com, R49496@freescale.com,
	stephen@networkplumber.org,
	christoph.muellner@theobroma-systems.com
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f181.google.com ([209.85.220.181]:59065 "EHLO
	mail-vc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751530Ab3F0NVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jun 2013 09:21:15 -0400
Received: by mail-vc0-f181.google.com with SMTP id lf11so257639vcb.40
        for <netdev@vger.kernel.org>; Thu, 27 Jun 2013 06:21:15 -0700 (PDT)
In-Reply-To: <20130627131503.GC2695@S2101-09.ap.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 27, 2013 at 10:15 AM, Shawn Guo <shawn.guo@linaro.org> wrote:
> On Thu, Jun 27, 2013 at 01:09:19PM +0800, Fugang Duan wrote:
>> When do suspend/resume, or plug/unplug network cable, or net watchdog
>> timeout process, fec_restart reinit the enet group hash table to zero.
>>
>> It is not reasonable for this, so re-config the enet group hash table
>> when these actions happen.
>>
>> Signed-off-by: Fugang Duan  <B38611@freescale.com>
>> ---
>>  drivers/net/ethernet/freescale/fec_main.c |  153 ++++++++++++++---------------
>>  1 files changed, 76 insertions(+), 77 deletions(-)
>
> A forward declaration of set_multicast_list() can simply save these
> dramatic diff stat?

Correct, and this has been already been posted:
http://patchwork.ozlabs.org/patch/253290/
