From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/1] net: caif: fix ineffective error check
Date: Sun, 4 Dec 2016 00:05:46 +0300
Message-ID: <218c3915-46f1-75e0-1a9b-f8cdc1789108@cogentembedded.com>
References: <1480763901-5323-1-git-send-email-bianpan2016@163.com>
 <f214a441-9e4b-6c40-f09d-32a6d1ea4dd0@cogentembedded.com>
 <20161203153535.GA7976@bp>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: PanBian <bianpan2016@163.com>,
        Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161203153535.GA7976@bp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 12/03/2016 06:38 PM, Pan Bian wrote:

>>> In function caif_sktinit_module(), the check of the return value of
>>> sock_register() seems ineffective. This patch fixes it.
>>>
>>> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=188751
>>>
>>> Signed-off-by: Pan Bian <bianpan2016@163.com>
>>> ---
>>> net/caif/caif_socket.c | 2 +-
>>> 1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
>>> index aa209b1..2a689a3 100644
>>> --- a/net/caif/caif_socket.c
>>> +++ b/net/caif/caif_socket.c
>>> @@ -1108,7 +1108,7 @@ static int caif_create(struct net *net, struct socket *sock, int protocol,
>>> static int __init caif_sktinit_module(void)
>>> {
>>> 	int err = sock_register(&caif_family_ops);
>>> -	if (!err)
>>> +	if (err)
>>> 		return err;
>>
>>    Why not just:
>>
>> 	return sock_register(&caif_family_ops);
>>
> 	Your solution looks much cleaner.
>
> 	But I am not really sure whether it is the author's intention to
> 	return 0 anyway. Do you have any idea?

    I don't think so, the error check seems to have a typo.

[...]

> Best regards,
> Pan

MBR, Sergei
