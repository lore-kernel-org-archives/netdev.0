From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Mellanox ethernet card failed when probing
Date: Fri, 03 Feb 2012 09:51:04 -0800
Message-ID: <4F2C1E88.1040304@hp.com>
References: <CAL8zT=gV=pe4Bnn188ngnPk8s=7JSGARY0g6uVHASVrUXNKeKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Jean-Michel Hautbois <jhautbois@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:19353 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757195Ab2BCRvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 12:51:07 -0500
In-Reply-To: <CAL8zT=gV=pe4Bnn188ngnPk8s=7JSGARY0g6uVHASVrUXNKeKg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/03/2012 07:13 AM, Jean-Michel Hautbois wrote:
> Hi all,
>
> I am using a HP server with Mellanox ethernet cards in it.
> I have compiled the latest linux 3.2 version, and I am encountering
> the following error :
>
> [ 1094.644193] mlx4_core: Mellanox ConnectX core driver v1.1 (Dec, 2011)
> [ 1094.644196] mlx4_core: Initializing 0000:06:00.0
> [ 1097.183671] mlx4_core 0000:06:00.0: irq 84 for MSI/MSI-X
> [ 1097.183681] mlx4_core 0000:06:00.0: irq 85 for MSI/MSI-X
> [ 1097.183690] mlx4_core 0000:06:00.0: irq 86 for MSI/MSI-X
> [ 1097.183697] mlx4_core 0000:06:00.0: irq 87 for MSI/MSI-X
> [ 1097.201267] mlx4_core: Initializing 0000:06:00.1
> [ 1097.201509] mlx4_core 0000:06:00.1: Multiple PFs not yet supported.
> Skipping PF.
> [ 1097.201844] mlx4_core: probe of 0000:06:00.1 failed with error -22
 > ...
> I think this is firmware related, but I don't know for sure.
> I can't find any firmware generated in the /lib/firmware directory...

That error message seems to relate to SRIOV support:

                 /* We reset the device and enable SRIOV only for physical
                  * devices.  Try to claim ownership on the device;
                  * if already taken, skip -- do not allow multiple PFs */
                 err = mlx4_get_ownership(dev);
                 if (err) {
                         if (err < 0)
                                 goto err_free_dev;
                         else {
                                 mlx4_warn(dev, "Multiple PFs not yet 
supported."
                                           " Skipping PF.\n");
                                 err = -EINVAL;
                                 goto err_free_dev;
                         }
                 }


Isn't SRIOV support a "work in progress" for the Mellanox devices?  The 
rest of the logging (snipped) seems to suggest that the ".0" PFs did 
initialize correctly, so are you simply worried about the messages in 
the log?

rick jones
