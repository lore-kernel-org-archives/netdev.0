From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH iproute2] ip: replace exit with return
Date: Wed, 12 Aug 2015 09:58:00 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB79494@AcuExch.aculab.com>
References: <1439286023-3648-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Zhang Shengju' <zhangshengju@cmss.chinamobile.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.191]:58196 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754167AbbHLKA0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 06:00:26 -0400
In-Reply-To: <1439286023-3648-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: netdev-owner@vger.kernel.org
> Sent: 11 August 2015 10:40
> In our manual, we have this description of 'EXIT STATUS':
> Exit status is 0 if command was successful, and 1 if there is a syntax
> error.
> 
> But we exit in command functions with code -1 when there is a syntax error.
> It's better to use return.

Eh?
Using exit() makes it much more obvious that the program is going to exit.

I've not looked at the call site (I'm not entirely sure where this code is
in the source tree), but main() shouldn't return -1 any more than exit(-1)
is invalid.
The domain for both is 0..127.
So the code should be using a valid value.

...
> diff --git a/ip/ipaddress.c b/ip/ipaddress.c
> index b7b4e3e..6d29a69 100644
> --- a/ip/ipaddress.c
> +++ b/ip/ipaddress.c
> @@ -1879,5 +1879,5 @@ int do_ipaddr(int argc, char **argv)
>  	if (matches(*argv, "help") == 0)
>  		usage();
>  	fprintf(stderr, "Command \"%s\" is unknown, try \"ip addr help\".\n", *argv);
> -	exit(-1);
> +	return -1;
>  }
...

	David
