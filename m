From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] IPv6: Privacy Extensions for Stateless Address Autoconfiguration in IPv6
Date: Tue, 25 Feb 2003 16:06:34 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030225160634.A4525@infradead.org>
References: <20030223.223114.65976206.davem@redhat.com> <20030224.155852.611429637.yoshfuji@linux-ipv6.org> <20030223.225251.119557134.davem@redhat.com> <20030226.003625.90530451.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@?(B" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20030226.003625.90530451.yoshfuji@linux-ipv6.org>; from yoshfuji@linux-ipv6.org on Wed, Feb 26, 2003 at 12:36:25AM +0900
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Feb 26, 2003 at 12:36:25AM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@?(B wrote:
> +#
> +if [ "$CONFIG_IPV6_PRIVACY" = "y" ]; then
> +  if [ "$CONFIG_IPV6" = "y" ]; then
> +    define_tristate CONFIG_MD5 y
> +  else
> +    define_tristate CONFIG_MD5 m
> +  fi
> +else
> +  tristate 'MD5 digest support' CONFIG_MD5
> +fi

Config.in files use three-space indents.

> +obj-$(CONFIG_MD5) += md5.o
> +ifeq ($(CONFIG_MD5),y)
> +  export-objs += md5.o
> +endif

this is wrong, objects are added to export-objs unconditional.

> +
> +#ifdef CONFIG_MD5
> +EXPORT_SYMBOL(MD5Init);
> +EXPORT_SYMBOL(MD5Update);
> +EXPORT_SYMBOL(MD5Final);
> +EXPORT_SYMBOL(MD5Transform);
> +#endif

Please remove the ifdef, it doesn't make any sense.


Also I really wonder whether we want to add just md5.c to 2.4 or
backport the cryptoapi core with md5 as the only algorithm so far..
