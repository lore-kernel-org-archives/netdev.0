From: "David Laight" <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [patch] Fix handling of overlength pathname in AF_UNIX sun_path
Date: Wed, 18 Apr 2012 09:17:26 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6EE2@saturn3.aculab.com>
References: <CADZpyix6DZ93f8MQf3Aa1NVV7HCFMAXVAdzRMFBY7xWHHQMPog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<penguin-kernel-1yMVhJb1mP/7nzcFbJAaVXf5DAMn2ifp@public.gmane.org>, <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>, <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>, <w@1wt.eu>,
	<alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
To: "Carlos O'Donell" <carlos-v2tUB8YBRSi3e3T8WW9gsA@public.gmane.org>,
	"David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <CADZpyix6DZ93f8MQf3Aa1NVV7HCFMAXVAdzRMFBY7xWHHQMPog-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

 
> 
> Why not have:
> 
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index d510353..f9f77a7 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -216,6 +216,9 @@ static int unix_mkname(struct sockaddr_un
> *sunaddr, int len, unsigned *hashp)
>                  */
>                 ((char *)sunaddr)[len] = 0;
>                 len = strlen(sunaddr->sun_path)+1+sizeof(short);
> +               /* No null terminator was found in the path. */
> +               if (len > sizeof(*sunaddr))
> +                       return -EINVAL;
>                 return len;

That could generate a kernel page fault!
(Depending on what follows (or rather doesn't follow!) sun_path.)
You'd need to use memchr() not strlen().

	David
