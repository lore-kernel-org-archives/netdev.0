From: Dan Carpenter <error27@gmail.com>
Subject: Re: [patch] eicon: make buffer larger
Date: Wed, 6 Oct 2010 09:47:14 +0200
Message-ID: <20101006074714.GE5409@bicker>
References: <20101004192459.GE5692@bicker> <alpine.DEB.2.00.1010060923120.29107@justus.melware.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Armin Schindler <armin@melware.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:43825 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932492Ab0JFHr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 03:47:28 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1010060923120.29107@justus.melware.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 06, 2010 at 09:25:44AM +0200, Armin Schindler wrote:
> On Mon, 4 Oct 2010, Dan Carpenter wrote:
>> In diva_mnt_add_xdi_adapter() we do this:
>>  strcpy (clients[id].drvName,     tmp);
>>  strcpy (clients[id].Dbg.drvName, tmp);
>>
>> The "clients[id].drvName" is a 128 character buffer and
>> "clients[id].Dbg.drvName" was originally a 16 character buffer but I've
>> changed it to 128 as well.  We don't actually use 128 characters but we
>> do use more than 16.
>
> I don't see any reason for that change. The driver names here do not use  
> more than 16 characters and when filled, the length is checked anyway.
> Please avoid changing the size of that structure.
>

drivers/isdn/hardware/eicon/debug.c diva_mnt_add_xdi_adapter()
   874      sprintf (tmp, "ADAPTER:%d SN:%u-%d",
                           12345678 90123 45 67

	That's a minimum 17 characters.

   875               (int)logical,
   876               serial & 0x00ffffff,
   877               (byte)(((serial & 0xff000000) >> 24) + 1));
   878    } else {
   879      sprintf (tmp, "ADAPTER:%d SN:%u", (int)logical, serial);
   880    }

regards,
dan carpenter

> Armin

