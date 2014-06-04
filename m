From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v10 1/7] xen-netback: Move grant_copy_op array
 back into struct xenvif.
Date: Wed, 04 Jun 2014 19:00:08 +0400
Message-ID: <538F3478.8040108@cogentembedded.com>
References: <1401874247-3202-1-git-send-email-wei.liu2@citrix.com> <1401874247-3202-2-git-send-email-wei.liu2@citrix.com> <538F3152.80501@cogentembedded.com> <538F32C4.8070409@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, zoltan.kiss@citrix.com,
	paul.durrant@citrix.com, a.j.bennieston@gmail.com,
	"Andrew J. Bennieston" <andrew.bennieston@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>, xen-devel@lists.xen.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:52168 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752652AbaFDPAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 11:00:04 -0400
Received: by mail-lb0-f169.google.com with SMTP id s7so4441237lbd.0
        for <netdev@vger.kernel.org>; Wed, 04 Jun 2014 08:00:02 -0700 (PDT)
In-Reply-To: <538F32C4.8070409@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/04/2014 06:52 PM, David Vrabel wrote:

>>> This array was allocated separately in commit ac3d5ac2 ("xen-netback:
>>> fix guest-receive-side array sizes") due to it being very large, and a
>>> struct xenvif is allocated as the netdev_priv part of a struct
>>> net_device, i.e. via kmalloc() but falling back to vmalloc() if the
>>> initial alloc. fails.

>>> In preparation for the multi-queue patches, where this array becomes
>>> part of struct xenvif_queue and is always allocated through vzalloc(),
>>> move this back into the struct xenvif.

>>     Won't this cause an allocation failure and so break bisection at this
>> patch?

> No. As Andrew already said: "...falling back to vmalloc() if the
> initial alloc. fails."

    Ah, sorry, I've managed to forget about that part. :-/

> David

WBR, Sergei
