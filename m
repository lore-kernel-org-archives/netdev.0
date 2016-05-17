From: David Miller <davem@davemloft.net>
Subject: Re: linux-4.6/net/kcm/kcmsock.c:1508: bad if test ?
Date: Tue, 17 May 2016 12:44:13 -0400 (EDT)
Message-ID: <20160517.124413.1000589286930755736.davem@davemloft.net>
References: <CAMzoambRTmpCmM0upiM5PMZtEioSMpw3QB4k--OCvHKmhCnw7w@mail.gmail.com>
	<CAM_iQpWi4L-Dz92ce_nfvXJujEDKnmy_d6Ytsd0hLokvsSV3eA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linuxdev.baldrick@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dcb314@hotmail.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48355 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729AbcEQQoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 12:44:15 -0400
In-Reply-To: <CAM_iQpWi4L-Dz92ce_nfvXJujEDKnmy_d6Ytsd0hLokvsSV3eA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 17 May 2016 09:04:21 -0700

> On Mon, May 16, 2016 at 11:40 AM, David Binderman
> <linuxdev.baldrick@gmail.com> wrote:
>> Hello there,
>>
>> linux-4.6/net/kcm/kcmsock.c:1508]: (style) Checking if unsigned
>> variable 'copied' is less than zero.
>>
>> Source code is
>>
>>     if (copied < 0) {
>>
>> but
>>
>>    size_t copied;
>>
>> Suggest code rework.
> 
> Thanks for the report! I think the following patch is enough:
> 
> diff --git a/net/kcm/kcmsock.c b/net/kcm/kcmsock.c
> index 40662d73..8bfc390 100644
> --- a/net/kcm/kcmsock.c
> +++ b/net/kcm/kcmsock.c
> @@ -1483,7 +1483,7 @@ static ssize_t kcm_splice_read(struct socket
> *sock, loff_t *ppos,
>         long timeo;
>         struct kcm_rx_msg *rxm;
>         int err = 0;
> -       size_t copied;
> +       int copied;

Or 'ssize_t' since that is the return type of this function.
