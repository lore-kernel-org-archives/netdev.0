From: "Gao Feng" <gfree.wind@foxmail.com>
Subject: RE: [PATCH net v4 00/12] Fix possbile memleaks when fail to register_netdevice
Date: Wed, 3 May 2017 08:33:02 +0800
Message-ID: <000b01d2c3a4$d3b91260$7b2b3720$@foxmail.com>
References: <cover.1493699451.git.gfree.wind@foxmail.com> <20170502.153029.1605231216574026914.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <jiri@resnulli.us>, <mareklindner@neomailbox.ch>,
        <sw@simonwunderlich.de>, <a@unstable.cc>, <kuznet@ms2.inr.ac.ru>,
        <jmorris@namei.org>, <yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
        <steffen.klassert@secunet.com>, <herbert@gondor.apana.org.au>,
        <netdev@vger.kernel.org>
To: "'David Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg65.qq.com ([103.7.28.233]:56776 "EHLO smtpbg65.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750815AbdECAdO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 2 May 2017 20:33:14 -0400
In-Reply-To: <20170502.153029.1605231216574026914.davem@davemloft.net>
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, May 3, 2017 3:30 AM
> From: gfree.wind@foxmail.com
> Date: Tue,  2 May 2017 13:58:42 +0800
> 
[...]
> >
> > This solution doesn't only make sure free all resources in any case,
> > but also follows the original desgin that some resources could be kept
> > until the destructor executes normally after register the device
> > successfully.
> 
> I want to think about this some more.
> 
> It is really unfortunate that resources are allocated strictly from the
ndo_init()
> yet released in two different callbacks which are invoked only in certain
> (different) situations.
> 
> Just the fact that we have to make an internal netdev state test in the
> ndo_uninit callback to get this right is a big red flag to me.

Yes, I am very agree with you.
This fix is just like a workaround under current framework.

The root is that allocate in one spot, but free them at two spots.
It means all ndo_uninit need to handle this case if allocate some resource
and free them in the destructor.
It should be done by the framework.

I thought about if there was a better solution to fix it.
But I think it need to modify the framework of net_device, it seems not good
as a bug fix to net.git.

Best Regards
Feng
