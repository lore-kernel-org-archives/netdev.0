From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [PATCH 3/5] net/mlx4: fix some error handling in mlx4_multi_func_init()
Date: Wed, 10 Feb 2016 19:15:20 +0100
Message-ID: <87twlgtosn.fsf@rasmusvillemoes.dk>
References: <1455048677-19882-1-git-send-email-linux@rasmusvillemoes.dk>
	<1455048677-19882-4-git-send-email-linux@rasmusvillemoes.dk>
	<56BB0577.8000000@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yishai Hadas <yishaih@mellanox.com>, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	"jackm\@mellanox.com" <jackm@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>
To: Yishai Hadas <yishaih@dev.mellanox.co.il>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56BB0577.8000000@dev.mellanox.co.il> (Yishai Hadas's message of
	"Wed, 10 Feb 2016 11:40:07 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 10 2016, Yishai Hadas <yishaih@dev.mellanox.co.il> wrote:

>> @@ -2429,7 +2429,7 @@ err_thread:
>>   	flush_workqueue(priv->mfunc.master.comm_wq);
>>   	destroy_workqueue(priv->mfunc.master.comm_wq);
>>   err_slaves:
>> -	while (--i) {
>> +	while (i--) {
>
> This fix is wrong as it hits the case that i arrived the last value
> then below code will access to a non valid entry in the array.
>
> The expected fix should be:
> while (--i >= 0)
>

Huh? They're completely equivalent (given that i is necessarily
non-negative before we evaluate the loop condition). I don't really care
either way, but git grep says that 'while (i--)' is 5 times more common
than 'while (--i >= 0)'.

Rasmus
