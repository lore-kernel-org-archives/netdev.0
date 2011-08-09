From: Wang Shaoyan <stufever@gmail.com>
Subject: Re: [PATCH] gianfar: reduce stack usage in gianfar_ethtool.c
Date: Wed, 10 Aug 2011 00:37:54 +0800
Message-ID: <CANxBZFqdhbSttgf5C6UjmTvkS8BfHHbo2qSiftQtQCT0w=B07g@mail.gmail.com>
References: <1312904711-1855-1-git-send-email-wangshaoyan.pt@taobao.com>
	<1312906118.11924.8.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, Wang Shaoyan <wangshaoyan.pt@taobao.com>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1312906118.11924.8.camel@Joe-Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I thought kfree should not call, when kmalloc is failed. Now I think
is fine, thanks, it is much clearer

> Perhaps it'd be clearer to use:
>
> =A0 =A0 =A0 =A0local_rqfpr =3D kmalloc(...)
> =A0 =A0 =A0 =A0local_rqfcr =3D kmalloc(...)
> =A0 =A0 =A0 =A0if (!local_rqfpr || !local_rqfcr) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pr_err(...)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D -ENOMEM;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto err;
> =A0 =A0 =A0 =A0}
>
> [...]
>
> err:
> =A0 =A0 =A0 =A0kfree(local_rqfpr);
> =A0 =A0 =A0 =A0kfree(local_rqfcr);
> =A0 =A0 =A0 =A0return ret;
>
> Is the "local_" prefix useful?
> It seems like visual noise to me.

They are some temporary variable, we better to left them

>
>



--=20
Wang Shaoyan
