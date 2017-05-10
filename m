From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] libertas: Avoid reading past end of buffer
Date: Wed, 10 May 2017 16:12:54 -0700
Message-ID: <1494457974.2028.3.camel@perches.com>
References: <20170510192451.GA115771@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Daniel Micay <danielmicay-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170510192451.GA115771@beast>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-05-10 at 12:24 -0700, Kees Cook wrote:
> Using memcpy() from a string that is shorter than the length copied means
> the destination buffer is being filled with arbitrary data from the kernel
> rodata segment. 

another bit of trivia:

> diff --git a/drivers/net/wireless/marvell/libertas/mesh.c b/drivers/net/wireless/marvell/libertas/mesh.c
[]
> @@ -1170,17 +1170,11 @@ int lbs_mesh_ethtool_get_sset_count(struct net_device *dev, int sset)
[]
> +		memcpy(s, *mesh_stat_strings, sizeof(mesh_stat_strings));

That * isn't necessary.
