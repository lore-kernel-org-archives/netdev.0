From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH] IPV6: fix payload length of reassembled packet
Date: Wed, 11 Jun 2003 20:15:45 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0306112014560.2321-100000@netcore.fi>
References: <20030612.020716.37975763.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: davem@redhat.com, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030612.020716.37975763.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 12 Jun 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:
> I've introduced a bug, which calculates payload length
> incorrectly when reassembling.
> Bug was introduced in ChangeSet 1.1229.7.40.
> (This patch also eliminates redundancy.)
> 
> Thanks in advance.
> 
> Index: linux-2.5/net/ipv6/reassembly.c
> ===================================================================
> RCS file: /home/cvs/linux-2.5/net/ipv6/reassembly.c,v
> retrieving revision 1.15
> diff -u -r1.15 reassembly.c
> --- linux-2.5/net/ipv6/reassembly.c	30 May 2003 17:46:04 -0000	1.15
> +++ linux-2.5/net/ipv6/reassembly.c	11 Jun 2003 15:49:44 -0000
> @@ -596,10 +596,8 @@
>  	BUG_TRAP(FRAG6_CB(head)->offset == 0);
>  
>  	/* Unfragmented part is taken from the first segment. */
> -	payload_len = (head->data - head->nh.raw) - sizeof(struct ipv6hdr) + fq->len;
> -	nhoff = head->h.raw - head->nh.raw;
> -
> -	if (payload_len > 65535 + 8)
> +	payload_len = (head->data - head->nh.raw) - sizeof(struct ipv6hdr) + fq->len - 8;

s/8/sizeof(struct frag_hdr)/ ?

> +	if (payload_len > 65535)
>  		goto out_oversize;
>  
>  	/* Head of list must not be cloned. */
> 
> 

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
