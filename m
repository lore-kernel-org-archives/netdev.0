From: Max Krasnyanskiy <maxk@qualcomm.com>
Subject: Re: [PATCH net-2.6.26 3/3][TUN][NETNS]: Allow to register tun devices
 in namespace.
Date: Wed, 02 Apr 2008 15:54:29 -0700
Message-ID: <47F40EA5.1030705@qualcomm.com>
References: <47F391BE.20008@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:33903 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755995AbYDBWyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 18:54:31 -0400
In-Reply-To: <47F391BE.20008@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pavel,

All three patches look perfectly fine to me.
Feel free to add Acked-by: Max Krasnyansky <maxk@qualcomm.com>

Pavel Emelyanov wrote:
> This is basically means that a net is set for a new device, but
> actually this involves two more steps:
> 
> 1. mark the tun device as "local", i.e. do not allow for it to
>    move across namespaces.
> 
> This is done so, since tun device is most often associated to some
> file (and thus to some process) and moving the device alone is not
> valid while keeping the file and the process outside.
> 
> 2. get the tun device's net when tun becomes attached and put one
>    when it becomes detached.
> 
> This is needed to handle the case when a task owning the tun dies,
> but a files lives for some more time - in this case we must not
> allow for net to be freed, since its exit hook will spoil that file's
> private data by unregistering the tun from under tun_chr_close.
I'm not sure what you mean "by file lives on" here. I believe you're talking 
about persistent tun devices. ie Those that exist in detached state and are 
not attached to any file descriptors.
"net" refcounting logic there looks fine to me.

Max


