From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: natsemi.c ioctl fix or mii register access
Date: Thu, 22 May 2008 14:04:48 -0400
Message-ID: <4835B5C0.2000701@pobox.com>
References: <010200463BAAFF45926C5BFD8E21F515F523F0@cos-us-mb01.cos.agilent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: glenn_engel@agilent.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:35067 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754737AbYEVSEv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 14:04:51 -0400
In-Reply-To: <010200463BAAFF45926C5BFD8E21F515F523F0@cos-us-mb01.cos.agilent.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

glenn_engel@agilent.com wrote:
> Hi,
> 
> I recently discovered the ioctl implementation in natsemi.c had a few bugs in dealing with the user ioctls to send and receive MII commands (SIOCGMIIPHY and SIOCSMIIPHY).
>  
> The specific problems noted and fixed:
> 
> 1. The if_mii macro casts it's return to be (struct mii_ioctl_data *) but in reality it returns a pointer to the user space pointer (struct mii_ioctl_data**).   This looks to be a problem with the mii_macro to me.  I changed this to use the ifr_data macro instead.
> 
> 2. Since the mii_ioctl_data structure resides in user space, it must be copied into kernel space before access and copied back for read results.  References to the pointer were changed to point to the local copy (data-> changed to mii_data.)

This is completely incorrect.  The copying is done for us inside net core.

	Jeff



