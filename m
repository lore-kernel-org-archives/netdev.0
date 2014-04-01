From: Joe Perches <joe@perches.com>
Subject: Re: [bug report] buffer overflow in isdn capi
Date: Tue, 01 Apr 2014 09:25:48 -0700
Message-ID: <1396369548.21529.79.camel@joe-AO722>
References: <20140401154830.GA16759@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0120.hostedemail.com ([216.40.44.120]:59631 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751363AbaDAQZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 12:25:53 -0400
In-Reply-To: <20140401154830.GA16759@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-04-01 at 18:48 +0300, Dan Carpenter wrote:
> The command_2_index() function is buggy and leads to a buffer overflow.
> Does anyone know how to fix this?
> 
> drivers/isdn/capi/capiutil.c
>    403  static unsigned command_2_index(unsigned c, unsigned sc)

These arguments should be u8 as well.

>    404  {
>    405          if (c & 0x80)
>    406                  c = 0x9 + (c & 0x0f);
>    407          else if (c <= 0x0f);
>    408          else if (c == 0x41)
>    409                  c = 0x9 + 0x1;
>    410          else if (c == 0xff)
>    411                  c = 0x00;
>    412          return (sc & 3) * (0x9 + 0x9) + c;
>    413  }
> 
> Imagine that we input c = 0x7f and sc = 0x3.  Then 3 * 18 + 127 = 181
> and we return 181.
> 
> The other thing that stands out to me is that the last condition
> "(c == 0xff)" is never true because then the first condition
> "(c & 0x80)" would have been true already.
