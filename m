From: James Morris <jmorris@namei.org>
Subject: Re: [RFC PATCH v6 15/16] cipso: Add support for native local labeling
 and fixup mapping names
Date: Wed, 1 Oct 2008 20:09:30 +1000 (EST)
Message-ID: <alpine.LRH.1.10.0810012003170.6732@tundra.namei.org>
References: <20080916124722.17132.38741.stgit@flek.lan> <20080916125730.17132.74360.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080916125730.17132.74360.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 16 Sep 2008, Paul Moore wrote:

> +/* Base length of the local tag (non-standard tag).
> + *  Tag definition (may change between kernel versions)
> + *
> + * 0          8          16         24         32
> + * +----------+----------+----------+----------+
> + * | 10000000 | 00001000 | unused (zero fill)  |
> + * +----------+----------+----------+----------+
> + * |   32-bit secid value (host byte order)    |
> + * +----------+----------+----------+----------+
> + *
> + */
> +#define CIPSO_V4_TAG_LOC_BLEN         8
> +

> +static int cipso_v4_gentag_loc(const struct cipso_v4_doi *doi_def,
> +			       const struct netlbl_lsm_secattr *secattr,
> +			       unsigned char *buffer,
> +			       u32 buffer_len)
> +{
> +	if (!(secattr->flags & NETLBL_SECATTR_SECID))
> +		return -EPERM;
> +
> +	buffer[0] = 0x80;
> +	buffer[1] = 0x08;
> +	*(u32 *)&buffer[4] = secattr->attr.secid;
> +
> +	return 8;
> +}

Macros would be nice for these, and why specify zero filling?  (Setting 
and testing that would be wasted cycles, if you enforced it).


- James
-- 
James Morris
<jmorris@namei.org>
