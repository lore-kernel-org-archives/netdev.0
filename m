From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: net: return actual error on register_queue_kobjects
Date: Thu, 19 Jun 2014 14:39:41 -0700
Message-ID: <CAADnVQ+OG=XSc+wx7RLefmiDm8uEegfgEyGtAA8=P+kG1m=n4g@mail.gmail.com>
References: <20140619212840.GA15522@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: jeff.liu@oracle.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:41424 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965141AbaFSVjm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2014 17:39:42 -0400
Received: by mail-qg0-f45.google.com with SMTP id 63so2645092qgz.18
        for <netdev@vger.kernel.org>; Thu, 19 Jun 2014 14:39:42 -0700 (PDT)
In-Reply-To: <20140619212840.GA15522@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 19, 2014 at 2:28 PM, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> Hello Jie Liu,
>
> The patch d36a4f4b4723: "net: return actual error on
> register_queue_kobjects" from Jun 17, 2014, leads to the following
> static checker warning:
>
>         net/core/net-sysfs.c:1203 register_queue_kobjects()
>         warn: 'net->queues_kset' isn't an ERR_PTR
>
> net/core/net-sysfs.c
>   1200  #ifdef CONFIG_SYSFS
>   1201          net->queues_kset = kset_create_and_add("queues",
>                                    ^^^^^^^^^^^^^^^^^^^
> This function returns a NULL on error doesn't it?  In linux-next it
> does.  The patch description is not clear.

that patch is broken and should be reverted as Jeff said:

--
From: Jeff Liu <jeff.liu@oracle.com>

> You will have to watch very carefully to ensure that those patches do
> not now get accepted, as they will break the existing code.

Ok, and I'll inform every other maintainers do not apply their patch
individually.

Cheers,
-Jeff

--

From: Jeff Liu <jeff.liu@oracle.com>
Yes, could you please remove this patch? sorry for the convenient!

--
