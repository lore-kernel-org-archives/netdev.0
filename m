From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [iproute PATCH v3 6/6] misc/ifstat: simplify unsigned value
 comparison
Date: Fri, 24 Jun 2016 09:20:32 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D5F4E3EA0@AcuExch.aculab.com>
References: <1466703254-5174-1-git-send-email-phil@nwl.cc>
 <1466703254-5174-7-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Phil Sutter' <phil@nwl.cc>,
	Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.195]:59946 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751355AbcFXJWo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 05:22:44 -0400
In-Reply-To: <1466703254-5174-7-git-send-email-phil@nwl.cc>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter
> Sent: 23 June 2016 18:34
> 
> By directly comparing the value of both unsigned variables, casting to
> signed becomes unnecessary.
> 
> This also fixes for compiling with older versions of gcc (at least
> <=3.4.6) which emit the following warning:
> 
> | ifstat.c: In function `update_db':
> | ifstat.c:542: warning: comparison is always false due to limited range of data type
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  misc/ifstat.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/misc/ifstat.c b/misc/ifstat.c
> index abbb4e732fcef..9a44da487599e 100644
> --- a/misc/ifstat.c
> +++ b/misc/ifstat.c
> @@ -539,7 +539,7 @@ static void update_db(int interval)
>  				int i;
> 
>  				for (i = 0; i < MAXS; i++) {
> -					if ((long)(h1->ival[i] - n->ival[i]) < 0) {
> +					if (h1->ival[i] < n->ival[i]) {
>  						memset(n->ival, 0, sizeof(n->ival));
>  						break;

That isn't the same check.
The original code is using modulo arithmetic.

	David
