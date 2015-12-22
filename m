From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V2 3/4] net/mlx5e: Add HW timestamping (TS) support
Date: Tue, 22 Dec 2015 12:00:52 +0200
Message-ID: <CALzJLG_YKG+mO+H9Lv6kgMoYRdBjUBWQiAPzhehTe0vNaLmOwg@mail.gmail.com>
References: <1450647991-13736-1-git-send-email-saeedm@mellanox.com>
	<1450647991-13736-4-git-send-email-saeedm@mellanox.com>
	<20151221091509.GA2297@localhost.localdomain>
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
Received: from mail-yk0-f176.google.com ([209.85.160.176]:34060 "EHLO
	mail-yk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932162AbbLVKBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 05:01:12 -0500
Received: by mail-yk0-f176.google.com with SMTP id p130so158595475yka.1
        for <netdev@vger.kernel.org>; Tue, 22 Dec 2015 02:00:52 -0800 (PST)
In-Reply-To: <20151221091509.GA2297@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 21, 2015 at 11:15 AM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Sun, Dec 20, 2015 at 11:46:30PM +0200, Saeed Mahameed wrote:
>> +/* Should run once every mlx5e_tstamp->overflow_period */
>> +static void mlx5e_timestamp_overflow(struct work_struct *work)
>> +{
>> +     struct delayed_work *dwork = to_delayed_work(work);
>> +     struct mlx5e_tstamp *tstamp = container_of(dwork, struct mlx5e_tstamp, overflow_work);
>> +     unsigned long flags;
>> +
>> +     write_lock_irqsave(&tstamp->lock, flags);
>> +     timecounter_read(&tstamp->clock);
>> +     if (tstamp->overflow_period)
>> +             schedule_delayed_work(&tstamp->overflow_work, tstamp->overflow_period);
>
> You don't need this test, and the call to schedule_delayed_work can be
> outside of the lock.
>
Ok, but what will happen if somehow tstamp->overflow_period is zero ?
the work will run too rapidly.
don't we need to have protection against such case.
