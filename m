From: Armin Schindler <armin@melware.de>
Subject: Re: [patch] eicon: make buffer larger
Date: Wed, 6 Oct 2010 10:44:47 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1010061043550.29582@justus.melware.de>
References: <20101004192459.GE5692@bicker> <alpine.DEB.2.00.1010060923120.29107@justus.melware.de> <20101006074714.GE5409@bicker> <alpine.DEB.2.00.1010061019480.29404@justus.melware.de> <20101006083117.GF5409@bicker>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.melware.net ([78.47.171.162]:59904 "EHLO mx1.melware.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752873Ab0JFIot (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Oct 2010 04:44:49 -0400
In-Reply-To: <20101006083117.GF5409@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 6 Oct 2010, Dan Carpenter wrote:
> On Wed, Oct 06, 2010 at 10:21:02AM +0200, Armin Schindler wrote:
>> On Wed, 6 Oct 2010, Dan Carpenter wrote:
>>> On Wed, Oct 06, 2010 at 09:25:44AM +0200, Armin Schindler wrote:
>>>> On Mon, 4 Oct 2010, Dan Carpenter wrote:
>>>>> In diva_mnt_add_xdi_adapter() we do this:
>>>>>  strcpy (clients[id].drvName,     tmp);
>>>>>  strcpy (clients[id].Dbg.drvName, tmp);
>>>>>
>>>>> The "clients[id].drvName" is a 128 character buffer and
>>>>> "clients[id].Dbg.drvName" was originally a 16 character buffer but I've
>>>>> changed it to 128 as well.  We don't actually use 128 characters but we
>>>>> do use more than 16.
>>>>
>>>> I don't see any reason for that change. The driver names here do not use
>>>> more than 16 characters and when filled, the length is checked anyway.
>>>> Please avoid changing the size of that structure.
>>>>
>>>
>>> drivers/isdn/hardware/eicon/debug.c diva_mnt_add_xdi_adapter()
>>>   874      sprintf (tmp, "ADAPTER:%d SN:%u-%d",
>>>                           12345678 90123 45 67
>>>
>>> 	That's a minimum 17 characters.
>>>
>>>   875               (int)logical,
>>>   876               serial & 0x00ffffff,
>>>   877               (byte)(((serial & 0xff000000) >> 24) + 1));
>>>   878    } else {
>>>   879      sprintf (tmp, "ADAPTER:%d SN:%u", (int)logical, serial);
>>>   880    }
>>
>> this is tmp with a bigger size. It seems you are mixing the sizes of
>> drvName and tmp.
>>
>
> What I mean is that later on we use strcpy() to copy "tmp" into
> "clients[id].Dbg.drvName"
>
>   927    strcpy (clients[id].drvName,     tmp);
>   928    strcpy (clients[id].Dbg.drvName, tmp);
>                               ^
>                    this buffer is only 16 chars

Now I understand. You are right. So the fix would be to change these 
strcpy() to e.g. strncpy() or similar.

Armin

