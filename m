From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: Re: [PATCH] RDS: Simplify code
Date: Sun, 4 Sep 2016 17:57:20 +0200
Message-ID: <befa1a39-cfc5-721f-e39a-369436237b1c@wanadoo.fr>
References: <1472880809-29216-1-git-send-email-christophe.jaillet@wanadoo.fr>
 <20160904122049.GQ21847@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Cc: santosh.shilimkar@oracle.com, davem@davemloft.net,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Leon Romanovsky <leon@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160904122049.GQ21847@leon.nu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 04/09/2016 à 14:20, Leon Romanovsky a écrit :
> On Sat, Sep 03, 2016 at 07:33:29AM +0200, Christophe JAILLET wrote:
>> Calling 'list_splice' followed by 'INIT_LIST_HEAD' is equivalent to
>> 'list_splice_init'.
> It is not 100% accurate
>
> list_splice(y, z)
> INIT_LIST_HEAD(y)
>
> ==>
>
> if (!list_empty(y))
>       __list_splice(y, z, z>next);
> INIT_LIST_HEAD(y)
>
> and not
>
> if (!list_empty(y)) {
>       __list_splice(y, z, z>next);
>       INIT_LIST_HEAD(y)
> }
>
> as list_splice_init will do.
>
You are right but if you dig further you will see that calling 
INIT_LIST_HEAD on an empty list is a no-op (AFAIK).
And if this list was not already correctly initialized, then you would 
have some other troubles.

CJ
