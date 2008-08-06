From: Krzysztof Oledzki <ole@ans.pl>
Subject: Re: [PATCH] AX.25: Fix sysctl registration if !CONFIG_AX25_DAMA_SLAVE
Date: Wed, 6 Aug 2008 04:35:59 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0808060427160.9293@bizon.gios.gov.pl>
References: <20080805223736.GA16608@linux-mips.org>
 <20080805.184737.158103058.davem@davemloft.net> <20080806015950.GM28946@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-1886318628-1217990159=:9293"
Cc: David Miller <davem@davemloft.net>, ralf@linux-mips.org,
	stable@kernel.org, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org, thomas@osterried.de,
	jann@linux-mips.org, dl5di@gmx.de
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20080806015950.GM28946@ZenIV.linux.org.uk>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-1886318628-1217990159=:9293
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Wed, 6 Aug 2008, Al Viro wrote:

> On Tue, Aug 05, 2008 at 06:47:37PM -0700, David Miller wrote:
>> From: Ralf Baechle <ralf@linux-mips.org>
>> Date: Tue, 5 Aug 2008 23:37:36 +0100
>>
>>> Since 49ffcf8f99e8d33ec8afb450956804af518fd788
>>> setting struct ctl_table.procname =3D NULL does no longer work as it us=
ed to
>>> the way the AX.25 code is expecting it to resulting in the AX.25 sysctl
>>> registration code to break if CONFIG_AX25_DAMA_SLAVE was not set as in =
some
>>> distribution kernels.  Kernel releases from 2.6.24 are affected.
>>>
>>> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
>>
>> Applied, and I'll queue it up for -stable too.
>
> BTW, here's netfilter sysctl one:

Please hold, still working on this.

> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> ---
> diff --git a/net/netfilter/core.c b/net/netfilter/core.c
> index 292fa28..655d743 100644
> --- a/net/netfilter/core.c
> +++ b/net/netfilter/core.c
> @@ -264,6 +264,12 @@ EXPORT_SYMBOL(proc_net_netfilter);
> void __init netfilter_init(void)
> {
> =09int i, h;
> +
> +#ifdef CONFIG_SYSCTL
> +=09static struct ctl_table empty[1];
> +=09register_sysctl_paths(nf_net_netfilter_sysctl_path, empty);
> +#endif

I think that instead of adding an empty nf_net_netfilter_sysctl_path=20
registration, it would be better to fix the order of register/unregister:

@@ -1032,10 +1032,10 @@
         nf_ct_free_hashtable(nf_conntrack_hash, nf_conntrack_vmalloc,
                              nf_conntrack_htable_size);

-       nf_conntrack_proto_fini();
-       nf_conntrack_helper_fini();
-       nf_conntrack_expect_fini();
         nf_conntrack_acct_fini();
+       nf_conntrack_expect_fini();
+       nf_conntrack_helper_fini();
+       nf_conntrack_proto_fini();
  }

I have a patch ready, only need to make some more tests.

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-1886318628-1217990159=:9293--
