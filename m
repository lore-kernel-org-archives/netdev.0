From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [Suggestion] net/atm : for sprintf, need check the total write length whether larger than a page.
Date: Tue, 04 Dec 2012 22:57:17 -0500
Message-ID: <201212050357.qB53vHvT022706@thirdoffive.cmf.nrl.navy.mil>
References: <50BEA2CB.9000800@asianux.com>
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:43722 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752590Ab2LED5e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2012 22:57:34 -0500
In-reply-to: <50BEA2CB.9000800@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <50BEA2CB.9000800@asianux.com>,Chen Gang writes:
>> -	for (i = 0; i < (ESI_LEN - 1); i++)
>> -		pos += sprintf(pos, "%02x:", adev->esi[i]);
>> -	pos += sprintf(pos, "%02x\n", adev->esi[i]);
>>  
>> -	return pos - buf;
>> +	return scnprintf(buf, PAGE_SIZE, "%pM\n", adev->esi);
>>  }
>>  
>
>  "%p" seems print a pointer, not contents of pointer (is it correct ?)
>  will it change the original display format to outside ?

%pM means format this pointer as a mac address.  it didnt exist when the
atm stack was originally written but can be used now to save a bit of
messy code.

>> -		pos += sprintf(pos, "\n");
>> +		count += scnprintf(buf + count, PAGE_SIZE - count, "\n");
...
>  need we judge whether count >= PAGE_SIZE ?

count will eventually make PAGE_SIZE - count reach 0 at which point,
scnprintf() won't be able to write into the buffer.
