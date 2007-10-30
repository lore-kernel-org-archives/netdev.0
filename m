From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/2] NFS: change the ip_map cache code to handle IPv6
	addresses
Date: Tue, 30 Oct 2007 14:49:01 -0400
Message-ID: <20071030184901.GJ21595@fieldses.org>
References: <47276466.4000402@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Brown <neilb@suse.de>,
	Mailing list NFSv4 <nfsv4@linux-nfs.org>,
	netdev ML <netdev@vger.kernel.org>
To: =?utf-8?B?QXVyw6lsaWVu?= Charbon <aurelien.charbon@ext.bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:45870 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751375AbXJ3StH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2007 14:49:07 -0400
Content-Disposition: inline
In-Reply-To: <47276466.4000402@ext.bull.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for working on this.

Could you run linux/scripts/checkpatch.pl on your patch and fix the
problems it complains about?

On Tue, Oct 30, 2007 at 06:05:42PM +0100, Aur=C3=A9lien Charbon wrote:
> static void update(struct cache_head *cnew, struct cache_head *citem)
> {
> @@ -149,22 +157,24 @@ static void ip_map_request(struct cache_
>                   struct cache_head *h,
>                   char **bpp, int *blen)
> {
> -    char text_addr[20];
> +    char text_addr[40];
>     struct ip_map *im =3D container_of(h, struct ip_map, h);
> -    __be32 addr =3D im->m_addr.s_addr;
> -
> -    snprintf(text_addr, 20, "%u.%u.%u.%u",
> -         ntohl(addr) >> 24 & 0xff,
> -         ntohl(addr) >> 16 & 0xff,
> -         ntohl(addr) >>  8 & 0xff,
> -         ntohl(addr) >>  0 & 0xff);
> +    if (ipv6_addr_v4mapped(&(im->m_addr))) {
> +        snprintf(text_addr, 20, NIPQUAD_FMT,
> +                ntohl(im->m_addr.s6_addr32[3]) >> 24 & 0xff,
> +                ntohl(im->m_addr.s6_addr32[3]) >> 16 & 0xff,
> +                ntohl(im->m_addr.s6_addr32[3]) >>  8 & 0xff,
> +                ntohl(im->m_addr.s6_addr32[3]) >>  0 & 0xff);
> +    } else {
> +        snprintf(text_addr, 40, NIP6_FMT, NIP6(im->m_addr));
> +    }
>     qword_add(bpp, blen, im->m_class);
>     qword_add(bpp, blen, text_addr);
>     (*bpp)[-1] =3D '\n';
> }

What happens when an unpatched mountd gets this request?  Does it
ignore it, or respond with a negative entry?

--b.
