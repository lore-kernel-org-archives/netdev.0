From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next] dsa: mv88e6xxx: Timeout based on iterations
Date: Wed, 17 Aug 2016 19:08:39 -0400
Message-ID: <87oa4rat8o.fsf@ketchup.mtl.sfl>
References: <1471469225-368-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:33547 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752797AbcHQXIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 19:08:44 -0400
In-Reply-To: <1471469225-368-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> The mv88e6xxx driver times out operations on the switch based on
> looping until an elapsed wall clock time is reached. However, if
> usleep_range() sleeps much longer than expected, it could timeout with
> an error without actually checking to see if the devices has completed
> the operation. So replace the elapsed time with a fixed upper bound on
> the number of loops.
>
> Testing on various switches has shown that switches takes either 0 or
> 1 iteration, so a maximum of 16 iterations is a safe limit.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
>  drivers/net/dsa/mv88e6xxx/chip.c | 15 ++++++---------
>  1 file changed, 6 insertions(+), 9 deletions(-)
>
> diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
> index a230fcba5b64..ac8e9af4879f 100644
> --- a/drivers/net/dsa/mv88e6xxx/chip.c
> +++ b/drivers/net/dsa/mv88e6xxx/chip.c
> @@ -309,9 +309,9 @@ static int mv88e6xxx_serdes_write(struct mv88e6xxx_chip *chip, int reg, u16 val)
>  static int mv88e6xxx_wait(struct mv88e6xxx_chip *chip, int addr, int reg,
>  			  u16 mask)
>  {
> -	unsigned long timeout = jiffies + HZ / 10;
> +	int i;
>  
> -	while (time_before(jiffies, timeout)) {
> +	for (i = 0; i < 16; i++) {
>  		u16 val;
>  		int err;
>  

Since we remove the elapsed time here, can we use mv88e6xxx_wait in
mv88e6xxx_update? It'd be good to have a consistent wait routine
everywhere.

Thanks,

        Vivien
