From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Use nfmark as a key for u32 classifier
Date: Tue, 09 Nov 2004 06:41:40 +0100
Message-ID: <41905894.7030809@trash.net>
References: <Pine.LNX.4.61.0411051317330.23651@webhosting.rdsbv.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, lartc@mailman.ds9a.nl, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
In-Reply-To: <Pine.LNX.4.61.0411051317330.23651@webhosting.rdsbv.ro>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Catalin(ux aka Dino) BOIE wrote:

> Hello!
>
> I am glad to announce a patch for u32 to allow matches on nfmark.
> The patch is non intrusive (few lines).
>
>------------------------------------------------------------------------
>
> 			if ((*(u32*)(ptr+key->off+(off2&key->offmask))^key->val)&key->mask) {
>--- linux.orig/include/linux/pkt_cls.h	2004-10-19 00:53:07.000000000 +0300
>+++ linux/include/linux/pkt_cls.h	2004-11-05 11:00:27.000000000 +0200
>@@ -208,6 +208,7 @@ struct tc_u32_sel
> 	unsigned char		flags;
> 	unsigned char		offshift;
> 	unsigned char		nkeys;
>+	u32			mark;
>  
>
^^ Please put this at the end to avoid breaking compatibility
with old tc binaries. BTW, nfmark if unsigned long, which is
64 bit on 64-bit architectures. Probably not worth fixing though,
everyone else got it wrong too.

> 
> 	__u16			offmask;
> 	__u16			off;
>  
>

Regards
Patrick
