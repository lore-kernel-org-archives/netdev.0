From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH RFC 1/31] net: Add net_namespace_type.h to allow for per
 network namespace variables.
Date: Thu, 25 Jan 2007 12:30:17 -0800
Message-ID: <20070125123017.1408941e@freekitty>
References: <m13b5zym0n.fsf@ebiederm.dsl.xmission.com>
	<11697516331146-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <containers@lists.osdl.org>,
	<openib-general@openib.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:52635 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030558AbXAYUfp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jan 2007 15:35:45 -0500
In-Reply-To: <11697516331146-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Can all this be a nop if a CONFIG option is not selected?




>
> diff --git a/include/linux/net_namespace_type.h b/include/linux/net_namespace_type.h
> new file mode 100644
> index 0000000..8173f59
> --- /dev/null
> +++ b/include/linux/net_namespace_type.h
> @@ -0,0 +1,52 @@
> +/* 
> + * Definition of the network namespace reference type
> + * And operations upon it.
> + */
> +#ifndef __LINUX_NET_NAMESPACE_TYPE_H
> +#define __LINUX_NET_NAMESPACE_TYPE_H
> +
> +#define __pernetname(name) per_net__##name

Code obfuscation, please don't do that

> +typedef struct {} net_t;

No typedef for this please.

> +
> +#define __data_pernet 
> +
> +/* Look up a per network namespace variable */
> +static inline unsigned long __per_net_offset(net_t net) { return 0; }
> +
> +/* Like per_net but returns a pseudo variable address that must be moved
> + * __per_net_offset() bytes before it will point to a real variable.
> + * Useful for static initializers.
> + */
> +#define __per_net_base(name)   __pernetname(name)
> +
> +/* Get the network namespace reference from a per_net variable address */
> +#define net_of(ptr, name) ({ net_t net; ptr; net; })
> +
> +/* Look up a per network namespace variable */
> +#define per_net(name, net) \
> +	(*(__per_net_offset(net), &__per_net_base(name)))
> + 
> +/* Are the two network namespaces the same */
> +static inline int net_eq(net_t a, net_t b) { return 1; }
> +/* Get an unsigned value appropriate for hashing the network namespace */
> +static inline unsigned int net_hval(net_t net) { return 0; }
> +
> +/* Convert to and from to and from void pointers */
> +static inline void *net_to_voidp(net_t net) { return NULL; }
> +static inline net_t net_from_voidp(void *ptr) { net_t net; return net; }
> +
> +static inline int null_net(net_t net) { return 0; }
> +
> +#define DEFINE_PER_NET(type, name) 			\
> +	__data_pernet __typeof__(type) __pernetname(name)
> +
> +#define DECLARE_PER_NET(type, name) \
> +	extern __typeof__(type) __pernetname(name)
> +
> +#define EXPORT_PER_NET_SYMBOL(var)	\
> +	EXPORT_SYMBOL(__pernetname(var))
> +#define EXPORT_PER_NET_SYMBOL_GPL(var)	\
> +	EXPORT_SYMBOL_GPL(__pernetname(var))
> +
> +#endif /* __LINUX_NET_NAMESPACE_TYPE_H */


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
