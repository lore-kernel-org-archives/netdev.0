From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [FYI PATCH] Ethernet over Cisco HDLC
Date: Thu, 24 Jun 2004 00:18:21 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3oen9yl3m.fsf@defiant.pm.waw.pl>
References: <Pine.LNX.4.44.0406231625490.7776-100000@dane-linux.aiinet.priv>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: dane@aiinet.com
In-Reply-To: <Pine.LNX.4.44.0406231625490.7776-100000@dane-linux.aiinet.priv> (Dan
 Eble's message of "Wed, 23 Jun 2004 16:37:06 -0400 (EDT)")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dan Eble <dane@aiinet.com> writes:

> I don't expect this patch to apply to any recent versions of the kernel.  
> I'm posting it in case there is someone interested in porting it.  If
> someone has the time to comment on the locking during dev destruction, I
> would appreciate receiving pointers.  Any other comments are welcome too.
>
> [To Krzysztof Halasa: All my mail to your pm.waw address bounces.  Is
> there an alternate address I can use to contact you?]

No (t yet).
It should now work (looks like HELO name of your mail server isn't
registered in DNS).

> --- Old/include/linux/if.h	2004-06-23 13:59:58.000000000 -0400
> +++ New/include/linux/if.h	2004-06-23 16:19:07.000000000 -0400
> @@ -69,20 +69,22 @@
>  #define IF_PROTO_CISCO	0x2002		/* Cisco HDLC protocol		*/
>  #define IF_PROTO_FR	0x2003		/* Frame Relay protocol		*/
>  #define IF_PROTO_FR_ADD_PVC 0x2004	/*    Create FR PVC		*/
>  #define IF_PROTO_FR_DEL_PVC 0x2005	/*    Delete FR PVC		*/
>  #define IF_PROTO_X25	0x2006		/* X.25				*/
>  #define IF_PROTO_HDLC_ETH 0x2007	/* raw HDLC, Ethernet emulation	*/
>  #define IF_PROTO_FR_ADD_ETH_PVC 0x2008	/*  Create FR Ethernet-bridged PVC */
>  #define IF_PROTO_FR_DEL_ETH_PVC 0x2009	/*  Delete FR Ethernet-bridged PVC */
>  #define IF_PROTO_FR_PVC	0x200A		/* for reading PVC status	*/
>  #define IF_PROTO_FR_ETH_PVC 0x200B
> +#define IF_PROTO_CISCO_ENABLE_PROTO 0x200C  /* enable an encapsulated proto  */
> +#define IF_PROTO_CISCO_DISABLE_PROTO 0x200D /* disable an encapsulated proto */

I wonder if we could merge IF_PROTO_FR_(ADD|DEL)_* and IF_PROTO_CISCO_*?
It would get us the same sethdlc syntax and similar add/del code.
-- 
Krzysztof Halasa, B*FH
