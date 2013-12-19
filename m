From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hyperv: Add support for Virtual Receive Side
 Scaling (vRSS)
Date: Thu, 19 Dec 2013 18:00:01 -0500 (EST)
Message-ID: <20131219.180001.2300376892730549121.davem@davemloft.net>
References: <CA+mtBx-BBBQjVTOrnaow=GNc7VM5D2Zj8xr=fPM4b4f_xT7qkQ@mail.gmail.com>
	<05be4f23ff784e56b710dd02eb88358a@DFM-DB3MBX15-08.exchange.corp.microsoft.com>
	<CA+mtBx_SSPd6s5519dWCyPGmFvO=kE+Fh3ZQ9w9oo=pJraRAFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: haiyangz@microsoft.com, dborkman@redhat.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org,
	kys@microsoft.com, olaf@aepfle.de, jasowang@redhat.com,
	linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org
To: therbert@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+mtBx_SSPd6s5519dWCyPGmFvO=kE+Fh3ZQ9w9oo=pJraRAFQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tom Herbert <therbert@google.com>
Date: Thu, 19 Dec 2013 13:43:06 -0800

> +       u32 v, r;
> +       int off, rem;
> +
> +       off = idx / 8;
> +       rem = idx % 8;
> +
> +       v = (((unsigned int)key[off]) << 24) +
> +           (((unsigned int)key[off + 1]) << 16) +
> +           (((unsigned int)key[off + 2]) << 8) +
> +           (((unsigned int)key[off + 3]));
> +
> +       r = v << rem | (unsigned int)key[off + 4] >> (8 - rem);

Minor nit, since the type you are using is "u32", that's probably what
you should be casting to in these spots instead of "unsigned int".
