From: "Gao Feng" <gfree.wind@foxmail.com>
Subject: RE: [PATCH net] driver/net: Fix possible memleaks when fail to register_netdevice
Date: Thu, 27 Apr 2017 16:33:09 +0800
Message-ID: <007001d2bf30$e751f850$b5f5e8f0$@foxmail.com>
References: <1493121710-27910-1-git-send-email-gfree.wind@foxmail.com> <20170427081559.GA1058@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <jiri@resnulli.us>, <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>,
        <jmorris@namei.org>, <yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
        <steffen.klassert@secunet.com>, <netdev@vger.kernel.org>,
        "'Gao Feng'" <fgao@ikuai8.com>
To: "'Herbert Xu'" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbgsg2.qq.com ([54.254.200.128]:48932 "EHLO smtpbgsg2.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933365AbdD0IdW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 04:33:22 -0400
In-Reply-To: <20170427081559.GA1058@gondor.apana.org.au>
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Herbert Xu [mailto:herbert@gondor.apana.org.au]
> Sent: Thursday, April 27, 2017 4:16 PM
> On Tue, Apr 25, 2017 at 08:01:50PM +0800, gfree.wind@foxmail.com wrote:
> > From: Gao Feng <fgao@ikuai8.com>
> >
[...]
> 
> This has the potential of creating future bugs, because there is no
guarantee
> that the ndo_init function has been invoked at all.
> 
> Wouldn't it be safer to move the freeing from the destructors into their
> ndo_uninit functions instead?

I considered about this solution, I am not sure if it is safe to move the
freeing from destructors into ndo_uninit.
Because when the free action is done in ndo_uninit, it is earlier than
destructor. 
I am not sure if it break the design of original driver.

I just tested the team driver before. It is ok to free all mems in
ndo_uninit.
Is it possible that anyone are using the net_dev after ndo_uninit ?

If no one, i would like to update the patch. 
Could you give me some guide please?

Regards
Feng

> 
> Thanks,
> --
