From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] atm: deal with setting entry before mkip was called
Date: Mon, 14 Sep 2015 09:50:50 -0700
Message-ID: <1442249450.14284.5.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1442245730-31575-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442245730-31575-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-09-14 at 11:48 -0400, Sasha Levin wrote:

> 
> diff --git a/net/atm/clip.c b/net/atm/clip.c
> index 17e55df..4407b2f 100644
> --- a/net/atm/clip.c
> +++ b/net/atm/clip.c
> @@ -317,6 +317,9 @@ static int clip_constructor(struct neighbour *neigh)
>  
>  static int clip_encap(struct atm_vcc *vcc, int mode)
>  {
> +	if (!CLIP_VCC(vcc))
> +		return -EBADF;
> +
>  	CLIP_VCC(vcc)->encap = mode;
>  	return 0;
>  }


-EBADF has a very precise meaning : /* Bad file number */

In this case, the file number is correct (and maps to a proper file),
but driver state is not allowing for this particular operation.
