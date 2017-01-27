From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] cfg80211 debugfs: Cleanup some checkpatch issues
Date: Fri, 27 Jan 2017 11:48:35 -0800
Message-ID: <1485546515.12563.138.camel@perches.com>
References: <20170127192603.GA13522@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Pichugin Dmitry <smokeman85@gmail.com>, johannes@sipsolutions.net,
        davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170127192603.GA13522@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-01-27 at 22:26 +0300, Pichugin Dmitry wrote:
> This fixes the checkpatch.pl warnings:
> * Macros should not use a trailing semicolon.
> * Spaces required around that '='.
> * Symbolic permissions 'S_IRUGO' are not preferred.

OK

> * Macro argument reuse 'buflen' - possible side-effects

Not all checkpatch messages need fixing.
This is one of them.

> diff --git a/net/wireless/debugfs.c b/net/wireless/debugfs.c
[]
> @@ -17,11 +17,12 @@
>  static ssize_t name## _read(struct file *file, char __user *userbuf,	\
>  			    size_t count, loff_t *ppos)			\
>  {									\
> -	struct wiphy *wiphy= file->private_data;		\
> -	char buf[buflen];						\
> +	struct wiphy *wiphy = file->private_data;			\
> +	int __buflen = __builtin_constant_p(buflen) ? buflen : -1;	\
> +	char buf[__buflen];						\

That's rather an odd change too
