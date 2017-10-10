From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/3] net/atm: Delete an error message for a failed
 memory allocation in five functions
Date: Mon, 09 Oct 2017 21:18:25 -0700
Message-ID: <1507609105.3552.18.camel@perches.com>
References: <10a92558-1105-b947-86a2-6ac763cca36d@users.sourceforge.net>
         <5270f15b-5e97-0c3e-3e55-fbded48ae07d@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: SF Markus Elfring <elfring@users.sourceforge.net>,
        netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Augusto Mecking Caringi <augustocaringi@gmail.com>,
        Bhumika Goyal <bhumirks@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        David Windsor <dwindsor@gmail.com>,
        Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        Jarod Wilson <jarod@redhat.com>,
        Johannes Berg <johannes.berg@intel.com>,
        Kees Cook <keescook@chromium.org>,
        Mitchell Blank Jr <mitch@sfgoth.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5270f15b-5e97-0c3e-3e55-fbded48ae07d@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-10-09 at 22:49 +0200, SF Markus Elfring wrote:
> Omit extra messages for a memory allocation failure in these functions.
[]
> diff --git a/net/atm/mpc.c b/net/atm/mpc.c
> @@ -184,10 +184,8 @@ struct atm_mpoa_qos *atm_mpoa_add_qos(__be32 dst_ip, struct atm_qos *qos)
>  	}
>  
>  	entry = kmalloc(sizeof(struct atm_mpoa_qos), GFP_KERNEL);
> -	if (entry == NULL) {
> -		pr_info("mpoa: out of memory\n");
> +	if (!entry)

Unspecified change.  Make sure your changelog is comprehensive.

>  		return entry;
> -	}

 
>  	entry->ipaddr = dst_ip;
>  	entry->qos = *qos;
> @@ -473,10 +471,8 @@ static const uint8_t *copy_macs(struct mpoa_client *mpc,
>  			kfree(mpc->mps_macs);
>  		mpc->number_of_mps_macs = 0;
>  		mpc->mps_macs = kmalloc(num_macs * ETH_ALEN, GFP_KERNEL);
> -		if (mpc->mps_macs == NULL) {
> -			pr_info("(%s) out of mem\n", mpc->dev->name);
> +		if (!mpc->mps_macs)
>  			return NULL;

etc...
