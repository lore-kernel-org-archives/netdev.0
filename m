From: Ohad Ben-Cohen <ohad@wizery.com>
Subject: Re: [RFC/PATCH 01/13] net: wl12xx: sdio: id_tables should be __devinitconst
Date: Fri, 20 May 2011 19:02:15 +0300
Message-ID: <BANLkTinsSuDj8vMYG-40aAw0UVwLDo2KDQ@mail.gmail.com>
References: <1305321990-22041-1-git-send-email-balbi@ti.com> <1305321990-22041-2-git-send-email-balbi@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Luciano Coelho <coelho@ti.com>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Felipe Balbi <balbi@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:61471 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757040Ab1ETQCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2011 12:02:37 -0400
In-Reply-To: <1305321990-22041-2-git-send-email-balbi@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 14, 2011 at 12:26 AM, Felipe Balbi <balbi@ti.com> wrote:
> That's only needed during init anyway, let's free
> some space after we're done probing.

sdio devices are dynamically created whenever the hw is plugged into
the mmc slot by the user. that can happen anytime while the system is
up, not only during init.

> -static const struct sdio_device_id wl1271_devices[] = {
> +static const struct sdio_device_id wl1271_devices[] __devinitconst = {

it looks to me that sdio_match_device is going to be surprised if
->id_table won't be valid.

i wouldn't do this, unless you have a good explanation otherwise.
