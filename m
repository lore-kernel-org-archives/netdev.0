From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] ipv4: ipmr_expire_timer causes crash when removing
 net namespace
Date: Tue, 21 Aug 2012 07:29:51 +0200
Message-ID: <1345526991.5158.373.camel@edumazet-glaptop>
References: <CA+HUmGgAx-APi4DRr=M2nUMfiO8yjcxovvqkTuX7=ZpUDbo5Tg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>
To: Francesco Ruggeri <fruggeri@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:41565 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751079Ab2HUF34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 01:29:56 -0400
Received: by wibhr14 with SMTP id hr14so4303778wib.1
        for <netdev@vger.kernel.org>; Mon, 20 Aug 2012 22:29:55 -0700 (PDT)
In-Reply-To: <CA+HUmGgAx-APi4DRr=M2nUMfiO8yjcxovvqkTuX7=ZpUDbo5Tg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-08-20 at 17:15 -0700, Francesco Ruggeri wrote:
> I
> +static void ipmr_free_table(struct mr_table *mrt)
> +{
> +	del_timer(&mrt->ipmr_expire_timer);
> +	mroute_clean_tables(mrt);
> +	kfree(mrt);
> +}

Seems racy to me.

del_timer() doesnt make sure timer is completely disabled.

Probably need spin_lock_bh(&mfc_unres_lock) /
spin_unlock_bh(&mfc_unres_lock), and maybe del_timer_sync()
