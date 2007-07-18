From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH 1/2] Fix error checking in Vitesse IRQ config
Date: Wed, 18 Jul 2007 13:52:52 -0500
Message-ID: <7318E17E-C9F9-42CE-89A4-E3DBAF0A02C6@freescale.com>
References: <11847405503115-git-send-email-afleming@freescale.com> <a901b49a0707180000g1c107323ub6c95a6ef3b5b2fe@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: pradeep singh <pradeep.rautela@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:34331 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759804AbXGRSxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 14:53:00 -0400
In-Reply-To: <a901b49a0707180000g1c107323ub6c95a6ef3b5b2fe@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Jul 18, 2007, at 02:00, pradeep singh wrote:

> On 7/18/07, Andy Fleming <afleming@freescale.com> wrote:

>> -               if (err)
>> +               if (err < 0)
>>                         return err;
>
> but would that mean, if phy_read returns > 0 it is a success?

Yes.  phy_read() returns a 32-bit value.  If there's an error, it  
returns a negative number.  If not, it returns whatever was in the  
register (which is only 16 bits)

phy_write() returns 0 on success, and non-zero, otherwise.  In  
hindsight, it would have been better to be consistent.

Andy
