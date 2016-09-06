From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH iproute2] ip route: check ftell, fseek return value
Date: Tue, 6 Sep 2016 11:18:00 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB00F5252@AcuExch.aculab.com>
References: <1473143990-9291-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Phil Sutter <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>
To: 'Hangbin Liu' <liuhangbin@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.183]:64477 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934093AbcIFLUn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 07:20:43 -0400
In-Reply-To: <1473143990-9291-1-git-send-email-liuhangbin@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hangbin Liu
> Sent: 06 September 2016 07:40
> ftell() may return -1 in error case, which is not handled and therefore pass a
> negative offset to fseek(). The return code of fseek() is also not checked.
> 
> Reported-by: Phil Sutter <phil@nwl.cc>
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> ---
>  ip/iproute.c | 11 +++++++++--
>  1 file changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/ip/iproute.c b/ip/iproute.c
> index 3da23af..ba877dc 100644
> --- a/ip/iproute.c
> +++ b/ip/iproute.c
> @@ -1859,7 +1859,11 @@ static int iproute_restore(void)
>  	if (route_dump_check_magic())
>  		exit(-1);
> 
> -	pos = ftell(stdin);
> +	if ((pos = ftell(stdin)) == -1) {

Don't put assignments in conditionals.

> +		perror("Failed to restore: ftell");
> +		exit(errno);

errno is not a valid argument to exit().

...

Actually WTF is this code trying to do.
stdin is very likely to be a pipe, so expecting to seek on it
seems very likely to fail.

	David
