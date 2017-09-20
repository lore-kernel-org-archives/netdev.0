From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: Latest net-next from GIT panic
Date: Wed, 20 Sep 2017 15:39:55 +0200
Message-ID: <686ea8f0-d9f8-82bc-ca68-f1d97614aa6b@itcare.pl>
References: <4745525f-18e4-7f69-fe21-8e507e407b33@itcare.pl>
 <d8bbf6c1-20a3-195c-6980-45f29e9f9278@itcare.pl>
 <2aeb7871-fe89-c714-3355-c5f48651e70c@itcare.pl>
 <15d293fa-0f53-bdca-6358-6a58d1da77af@itcare.pl>
 <65e2195b-3bd1-c0b4-b474-e07dd08f71b9@itcare.pl>
 <1505877870.29839.82.camel@edumazet-glaptop3.roam.corp.google.com>
 <07bde5d4-fab6-3ef9-f586-403dadbb0a2a@itcare.pl>
 <8f0b0143-657e-d574-c442-24d3d017bc87@itcare.pl>
 <54d058d4-b9d1-54cb-f064-45cec430fe5d@itcare.pl>
 <6c073f86-ab71-0a8f-7b9a-91d5ae5da214@itcare.pl>
 <7fee43ee-75b5-c2f5-cf8d-684ceefcd2d1@itcare.pl>
 <c278dec6-e018-62e0-a613-1fa79741aaab@itcare.pl>
 <cfc04422-51bd-0a28-6a8c-6b57179e8af2@itcare.pl>
 <3324f95f-7686-81e0-a973-1a9220c918fe@itcare.pl>
 <1505913075.29839.90.camel@edumazet-glaptop3.roam.corp.google.com>
 <07c29702-cd0b-32af-df0a-83ad24b8c785@itcare.pl>
 <1505914479.29839.92.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Wei Wang <weiwan@google.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        edumazet@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp16.iq.pl ([86.111.242.222]:60643 "EHLO smtp16.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751609AbdITNmF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 20 Sep 2017 09:42:05 -0400
In-Reply-To: <1505914479.29839.92.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



W dniu 2017-09-20 o 15:34, Eric Dumazet pisze:
> Could you try this debug patch ?
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index f535779d9dc1dfe36934c2abba4e43d053ac5d6f..1eaa3553a724dc8c048f67b556337072d5addc82 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -3331,7 +3331,14 @@ void netdev_run_todo(void);
>    */
>   static inline void dev_put(struct net_device *dev)
>   {
> -	this_cpu_dec(*dev->pcpu_refcnt);
> +	int __percpu *pref = READ_ONCE(dev->pcpu_refcnt);
> +
> +	if (!pref) {
> +		pr_err("no pcpu_refcnt on dev %p(%s) state %d dismantle %d\n",
> +		       dev, dev->name, dev->reg_state, dev->dismantle);
> +		BUG();
> +	}
> +	this_cpu_dec(*pref);
>   }
>   
>   /**
>
>
>

You want me to add this patch to what kernel version ?
currently im after git bisect reset - so mainline stable
