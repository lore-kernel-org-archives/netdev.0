From: Daniele Forsi <dforsi@gmail.com>
Subject: Re: [PATCH net-next 4/4] r8152: support firmware files
Date: Wed, 20 Aug 2014 14:01:07 +0200
Message-ID: <CAN_we7P2LDvR8miAsoSeL6+iEOK+ucgjRDC8jtPbc4_-2nn7MQ@mail.gmail.com>
References: <1394712342-15778-16-Taiwan-albertk@realtek.com>
	<1394712342-15778-20-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, USB list <linux-usb@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:62057 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752400AbaHTMBJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2014 08:01:09 -0400
In-Reply-To: <1394712342-15778-20-Taiwan-albertk@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-08-20 10:58 GMT+02:00 Hayes Wang:

> The firmware file is composed of the fw header and the commands. Each
> command has the following type.
>
>         cmd(2 bytes) + length(2 bytes) + data(variable bytes)

> +static bool rtl_fw_format_ok(struct rtl_fw *rtl_fw)

> +       start = le32_to_cpu(fw_header->fw_start);
> +       if (start > fw->size)
> +               goto out;

since "start" is an offset in an array of size "fw->size" this should
check for ">=" and if a command is at least cmd(2 bytes) + length(2
bytes), shouldn't this check for "start >= fw->size - 4"?

-- 
Daniele Forsi
