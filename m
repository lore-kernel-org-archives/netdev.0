From: Amir Noam <amir.noam@intel.com>
Subject: Re: [Bonding-devel] [PATCH] [bonding 2.4] Add balance-xor-ip bonding mode
Date: Thu, 8 Jan 2004 17:33:44 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401081733.44744.amir.noam@intel.com>
References: <E6F7D288B394A64585E67497E5126BA601F991D0@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <bonding-devel@lists.sourceforge.net>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Per Hedeland" <per@hedeland.org>
In-Reply-To: <E6F7D288B394A64585E67497E5126BA601F991D0@hasmsx403.iil.intel.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wednesday 07 January 2004 10:58 pm, Per Hedeland wrote:
>         struct bonding *bond = bond_dev->priv; 
>         struct ethhdr *data = (struct ethhdr *)skb->data; 
>         struct slave *slave, *start_at; 
> -       int slave_no; 
> +       int slave_no = 0; 
>         int i; 
> +       __u32 u; 
>  
>         read_lock(&bond->lock);
>

Please use u32 instead of __u32.


> +static int bond_xmit_xor_mac(struct sk_buff *skb, struct net_device *bond_dev) 
> +{ 
> +       return bond_xmit_xor(skb, bond_dev, 0); 
> +} 
> + 
> +static int bond_xmit_xor_ip(struct sk_buff *skb, struct net_device *bond_dev) 
> +{ 
> +       return bond_xmit_xor(skb, bond_dev, 1); 
> +} 
> +

hmm...

I don't like this. The reason we give different tx function pointers
to dev->hard_start_xmit in different bonding mode is to make the tx
path as fast as possible. Otherwise we might as well use a single tx
function that chooses its exact operation based on the bonding mode.

It might be better to have some code duplication if it results in
faster tx, but I'm not sure what's the optimal solution in this case.

-- 
Amir
