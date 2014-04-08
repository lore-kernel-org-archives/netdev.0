From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [patch] isdnloop: several buffer overflows
Date: Tue, 8 Apr 2014 09:34:09 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6F14A1@AcuExch.aculab.com>
References: <20140408092309.GA26450@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	YOSHIFUJI Hideaki / ???? <yoshfuji@linux-ipv6.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: 'Dan Carpenter' <dan.carpenter@oracle.com>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:47836 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1756126AbaDHJfr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 05:35:47 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 14379-04 for <netdev@vger.kernel.org>;
 Tue,  8 Apr 2014 10:35:38 +0100 (BST)
In-Reply-To: <20140408092309.GA26450@mwanda>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter
> There are three buffer overflows addressed in this patch.
...
> 2) In isdnloop_parse_cmd(), p points to a 6 characters into a 60
> character buffer so we have 54 characters.  The ->eazlist[] is 11
> characters long.  I have modified the code to return if the source
> buffer is too long.
...
> @@ -903,6 +903,8 @@ isdnloop_parse_cmd(isdnloop_card *card)
>  	case 7:
>  		/* 0x;EAZ */
>  		p += 3;
> +		if (strlen(p) >= sizeof(card->eazlist[0]))
> +			break;
>  		strcpy(card->eazlist[ch - 1], p);
>  		break;
>  	case 8:

If you've done the strlen() you might as well use memcpy().
There are also functions that will do a bounded strlen(),
(eg memchr()).

	David
