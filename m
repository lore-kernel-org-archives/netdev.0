From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH, netfilter] NUMA aware ipv4/netfilter/ip_tables.c
Date: Mon, 19 Sep 2005 19:20:55 +0200
Message-ID: <432EF377.3050402@cosmosbay.com>
References: <432EF0C5.5090908@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: netfilter-devel@lists.netfilter.org
In-Reply-To: <432EF0C5.5090908@cosmosbay.com>
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

Eric dumazet a =E9crit :
> Hi
>=20
> Part of the performance problem we have with netfilter  is memory=20
> allocation is not NUMA aware, but 'only' SMP aware.
>=20
> What do you think of this patch ?
>=20

...

> +#ifdef CONFIG_NUMA
> +		set_cpus_allowed(current, oldmask);
> +		mpol_free(current->mempolicy);
> +		current->mempolicy =3D oldpol;
> +#endif
> +		if (newinfo->entries[cpu] =3D=3D 0) {
> +			free_table_info(newinfo);
> +			return NULL;
> +		if (!newinfo->entry0)
> +			newinfo->entry0 =3D newinfo->entries[cpu];
> +		}   // ERROR
> +	}
> +	return newinfo;
> +}
> +

Oops sorry for this misplaced brace. It should be :

 > +#ifdef CONFIG_NUMA
 > +		set_cpus_allowed(current, oldmask);
 > +		mpol_free(current->mempolicy);
 > +		current->mempolicy =3D oldpol;
 > +#endif
 > +		if (newinfo->entries[cpu] =3D=3D 0) {
 > +			free_table_info(newinfo);
 > +			return NULL;
 > +             } // HERE
 > +		if (!newinfo->entry0)
 > +			newinfo->entry0 =3D newinfo->entries[cpu];
 > +	}
 > +	return newinfo;
 > +}
 > +
