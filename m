From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next V2 3/4] net/mlx5e: Add HW timestamping (TS)
 support
Date: Mon, 21 Dec 2015 19:35:08 +0100
Message-ID: <20151221183508.GA13533@localhost.localdomain>
References: <1450647991-13736-1-git-send-email-saeedm@mellanox.com>
 <1450647991-13736-4-git-send-email-saeedm@mellanox.com>
 <20151221091509.GA2297@localhost.localdomain>
 <CALzJLG-22OjP+CDjJuzm5_oHGRAvG1LZawBfi0UtGEEf5dbviQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:34500 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750870AbbLUSfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2015 13:35:15 -0500
Received: by mail-wm0-f42.google.com with SMTP id l126so80131723wml.1
        for <netdev@vger.kernel.org>; Mon, 21 Dec 2015 10:35:14 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CALzJLG-22OjP+CDjJuzm5_oHGRAvG1LZawBfi0UtGEEf5dbviQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 21, 2015 at 04:35:23PM +0200, Saeed Mahameed wrote:
> think of a case where:
> CPU1: is just about to call
> "schedule_delayed_work(&tstamp->overflow_work,
> tstamp->overflow_period);"
> CPU2: cancel_delayed_work
> 
> In this case cancel_dalyed_work_sync (CPU2) will wait for CPU1 to
> complete but CPU1 will re-arm the work, and we will
> be left with tstamp->overflow_work running forever.

This is my understanding:  Once the work becomes re-queued, it will be
canceled before running again.

Thanks,
Richard
