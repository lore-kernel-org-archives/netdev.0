From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V2 3/4] net/mlx5e: Add HW timestamping (TS) support
Date: Tue, 22 Dec 2015 11:56:56 +0200
Message-ID: <CALzJLG-cpwiaELzfVm2x879s88QEP7BD3_0KQ-ogd5MGxSfM-g@mail.gmail.com>
References: <1450647991-13736-1-git-send-email-saeedm@mellanox.com>
	<1450647991-13736-4-git-send-email-saeedm@mellanox.com>
	<20151221091509.GA2297@localhost.localdomain>
	<CALzJLG-22OjP+CDjJuzm5_oHGRAvG1LZawBfi0UtGEEf5dbviQ@mail.gmail.com>
	<20151221183508.GA13533@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:36756 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932172AbbLVJ45 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 04:56:57 -0500
Received: by mail-yk0-f177.google.com with SMTP id x184so159759207yka.3
        for <netdev@vger.kernel.org>; Tue, 22 Dec 2015 01:56:57 -0800 (PST)
In-Reply-To: <20151221183508.GA13533@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 21, 2015 at 8:35 PM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Mon, Dec 21, 2015 at 04:35:23PM +0200, Saeed Mahameed wrote:
>> think of a case where:
>> CPU1: is just about to call
>> "schedule_delayed_work(&tstamp->overflow_work,
>> tstamp->overflow_period);"
>> CPU2: cancel_delayed_work
>>
>> In this case cancel_dalyed_work_sync (CPU2) will wait for CPU1 to
>> complete but CPU1 will re-arm the work, and we will
>> be left with tstamp->overflow_work running forever.
>
> This is my understanding:  Once the work becomes re-queued, it will be
> canceled before running again.
True, will fix this.
Thanks

>
> Thanks,
> Richard
>
