From: "=?utf-8?B?bmhvcm1hbkB0dXhkcml2ZXIuY29t?=" <nhorman@tuxdriver.com>
Subject: Re:
	=?utf-8?q?Linux_2=2E6=2E35/TIPC_2=2E0_ABI_break?=
	=?utf-8?q?ing_changes?=
Date: Tue, 19 Oct 2010 21:09:39 -0400
Message-ID: <E1P8NBB-00040N-Pv@smtp.tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	=?utf-8?B?RGF2aWQgTWlsbGVy?= <davem@davemloft.net>
To: "=?utf-8?B?TGVhbmRybyBMdWNhcmVsbGE=?=" <luca@llucax.com.ar>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


Yeah. I might have missed that.  Although it did give me a.success message when I ran the test.  That's why I asked.Dave not to pull it yet :).  Well look at it.more closely in the am
Neil

Sent from my Verizon Wireless Phone

----- Reply message -----
From: "Leandro Lucarella" <luca@llucax.com.ar>
Date: Tue, Oct 19, 2010 4:43 pm
Subject: Linux 2.6.35/TIPC 2.0 ABI breaking changes
To: "Neil Horman" <nhorman@tuxdriver.com>
Cc: "David Miller" <davem@davemloft.net>, <paul.gortmaker@windriver.com>, <jon.maloy@ericsson.com>, <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>


Neil Horman, el 19 de octubre a las 16:18 me escribiste:
> Hey all-
> 	Heres what I have so far.  Dave as a heads up please don't apply this
> yet.  I'd like to go over it a bit more and be sure of the implications here
> before I post it for inclusion officially.  I wanted Leandro to have a copy
> though so he could confirm functionality for us.  Leandro, This patch lets me
> pass the tipc test code for TIPC 1.6 that you posted earlier this morning.  If
> you could confirm that it works for you that would be grand.  While your doing
> that, I want to read over the spec for TIPC and make sure that I'm not breaking
> anything new with this patch.

Thanks for the quick response. I didn't tried the patch yet, but I think
spotted an error:

> diff --git a/include/linux/tipc.h b/include/linux/tipc.h
> index 181c8d0..d8de884 100644
> --- a/include/linux/tipc.h
> +++ b/include/linux/tipc.h
> @@ -127,9 +127,10 @@ static inline unsigned int tipc_node(__u32 addr)
>   * TIPC topology subscription service definitions
>   */
>  
> -#define TIPC_SUB_SERVICE     	0x00  	/* Filter for service availability    */
> -#define TIPC_SUB_PORTS     	0x01  	/* Filter for port availability  */
> +#define TIPC_SUB_SERVICE     	0x01  	/* Filter for service availability    */
> +#define TIPC_SUB_PORTS     	0x02  	/* Filter for port availability  */
>  #define TIPC_SUB_CANCEL         0x04    /* Cancel a subscription         */
> +#define TIPC_SUB_MASK		(TIPC_SUB_SERVICE|TIPC_SUB_PORTS|TIPC_SUB_CANCEL)
>  
>  #define TIPC_WAIT_FOREVER	~0	/* timeout for permanent subscription */
>  

The values of TIPC_SUB_SERVICE and TIPC_SUB_PORTS seem to be swapped
compared to the old (TIPC 1.6) values:
#define TIPC_SUB_PORTS     	0x01  	/* filter for port availability */
#define TIPC_SUB_SERVICE     	0x02  	/* filter for service availability */

You might missed this error when trying the code I posted earlier (which
BTW are the official TIPC demos) because the change of behaviour when
using TIPC_SUB_SERVICE and TIPC_SUB_PORTS is very subtle (the former
reports only the first published port name that matches, and the later
all the published ports that match).

I'll test the patch tomorrow morning (ART).

Thanks again.

-- 
Leandro Lucarella (AKA luca)                     http://llucax.com.ar/
----------------------------------------------------------------------
GPG Key: 5F5A8D05 (F8CD F9A7 BF00 5431 4145  104C 949E BFB6 5F5A 8D05)
----------------------------------------------------------------------
Long you live and high you fly
And smiles you'll give and tears you'll cry
And all you touch and all you see
Is all your life will ever be.

------------------------------------------------------------------------------
Download new Adobe(R) Flash(R) Builder(TM) 4
The new Adobe(R) Flex(R) 4 and Flash(R) Builder(TM) 4 (formerly 
Flex(R) Builder(TM)) enable the development of rich applications that run
across multiple browsers and platforms. Download your free trials today!
http://p.sf.net/sfu/adobe-dev2dev
