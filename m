From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 01/14] Big kfree NULL check cleanup - net
Date: Fri, 14 Oct 2005 11:50:50 +0200
Message-ID: <1129283450.5057.29.camel@localhost.localdomain>
References: <200510132125.44470.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
	Ralf Baechle <ralf@linux-mips.org>,
	Greg Kroah-Hartman <greg@kroah.com>, dccp@vger.kernel.org,
	Patrick Caulfield <patrick@tykepenguin.com>,
	Jean Tourrilhes <jt@hpl.hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	Andy Adamson <andros@umich.edu>,
	"J. Bruce Fields" <bfields@umich.edu>,
	Nenad Corbic <ncorbic@sangoma.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750707AbVJNKAn@vger.kernel.org>
To: Jesper Juhl <jesper.juhl@gmail.com>
In-Reply-To: <200510132125.44470.jesper.juhl@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jesper,

> This is the net/ part of the big kfree cleanup patch.
> 
> Remove pointless checks for NULL prior to calling kfree() in net/.
> 
> 
> Sorry about the long Cc: list, but I wanted to make sure I included everyone
> who's code I've changed with this patch.

you forgot me ;)

> --- linux-2.6.14-rc4-orig/net/bluetooth/hidp/core.c	2005-08-29 01:41:01.000000000 +0200
> +++ linux-2.6.14-rc4/net/bluetooth/hidp/core.c	2005-10-13 11:47:49.000000000 +0200
> @@ -657,9 +657,7 @@ unlink:
>  failed:
>  	up_write(&hidp_session_sem);
>  
> -	if (session->input)
> -		kfree(session->input);
> -
> +	kfree(session->input);
>  	kfree(session);
>  	return err;
>  }

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Regards

Marcel
