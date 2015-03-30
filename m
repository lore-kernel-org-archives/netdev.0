From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH] Bonding Overriding Configuration logic restored.
Date: Mon, 30 Mar 2015 09:59:30 -0400
Message-ID: <20150330135910.GJ1051@gospo>
References: <1427628025-9752-1-git-send-email-anton@swortex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Alexey Bogoslavsky <alexey@swortex.com>
To: Anton Nayshtut <anton@swortex.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1427628025-9752-1-git-send-email-anton@swortex.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 29, 2015 at 02:20:25PM +0300, Anton Nayshtut wrote:
> Before commit 3900f29021f0bc7fe9815aa32f1a993b7dfdd402 ("bonding: slight
> optimizztion for bond_slave_override()") the override logic was to send packets
> with non-zero queue_id through the slave with corresponding queue_id, under two
> conditions only - if the slave can transmit and it's up.
> 
> The above mentioned commit changed this logic by introducing an additional
> condition - whether the bond is active (indirectly, using the slave_can_tx and
> later - bond_is_active_slave), that prevents the user from implementing more
> complex policies according to the Documentation/networking/bonding.txt.
Yes, this does.  Good catch.

> Signed-off-by: Anton Nayshtut <anton@swortex.com>
> Signed-off-by: Alexey Bogoslavsky <alexey@swortex.com>
Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>

> ---
>  drivers/net/bonding/bond_main.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 0dceba1..68ad39a 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -3797,7 +3797,8 @@ static inline int bond_slave_override(struct bonding *bond,
>  	/* Find out if any slaves have the same mapping as this skb. */
>  	bond_for_each_slave_rcu(bond, slave, iter) {
>  		if (slave->queue_id == skb->queue_mapping) {
> -			if (bond_slave_can_tx(slave)) {
> +			if (bond_slave_is_up(slave) &&
> +			    slave->link == BOND_LINK_UP) {
>  				bond_dev_queue_xmit(bond, skb, slave->dev);
>  				return 0;
>  			}
> -- 
> 1.9.1
> 
