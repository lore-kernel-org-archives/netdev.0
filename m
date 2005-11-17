From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] [RFT] ip_tables NUMA optimization
Date: Thu, 17 Nov 2005 16:21:45 +0100
Message-ID: <437CA009.4020006@cosmosbay.com>
References: <20051117144328.GG14201@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20051117144328.GG14201@sunbeam.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Harald Welte a =E9crit :
> I've hand-merged Eric Dumazet's original ip_tables numa optimization
> patch to current git head.  Also, I've ported it to ip6_tables and
> arp_tables.
>=20
> Since this is 2.6.16 stuff, I don't want to have it applied at this
> time, but merely request testers (esp. for the non-ipv4 part).
>=20
> Thanks,
>=20

Hi Harald

Thank you for doing this, since I'm currently too busy with my day job to=
=20
update the patch myself.

However I did read your patch and caught one vfree() call wrongly replace=
d by=20
a kfree() call in arp_tables.c


>
> @@ -911,6 +930,47 @@ static int get_entries(const struct arpt
>  	return ret;
>  }
> =20
> +static void free_table_info(struct arpt_table_info *info)
> +{
> +	int cpu;
> +	for_each_cpu(cpu) {
> +		if (info->size <=3D PAGE_SIZE)
> +			kfree(info->entries[cpu]);
> +		else
> +			kfree(info->entries[cpu]);   !!!!
> +	}
> +	kfree(info);


It should probably use vfree() like :

 > +	for_each_cpu(cpu) {
 > +		if (info->size <=3D PAGE_SIZE)
 > +			kfree(info->entries[cpu]);
 > +		else
 > +			vfree(info->entries[cpu]);
 > +	}


See you

Eric Dumazet
