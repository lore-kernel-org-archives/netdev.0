From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: Resend [PATCH] netfilter: Fix copy_to_user too small size parametre.
Date: Fri, 2 Mar 2012 09:05:10 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6E87@saturn3.aculab.com>
References: <1330621743-12883-1-git-send-email-santoshprasadnayak@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <pablo@netfilter.org>, <kaber@trash.net>, <shemminger@vyatta.com>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>,
	<netfilter-devel@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-janitors@vger.kernel.org>
To: "santosh nayak" <santoshprasadnayak@gmail.com>,
	<bart.de.schuymer@pandora.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <1330621743-12883-1-git-send-email-santoshprasadnayak@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
> -	if (copy_to_user(hlp, m->u.match->name, 
> EBT_FUNCTION_MAXNAMELEN))
> +	char name[EBT_FUNCTION_MAXNAMELEN] = {};
> +
> +	strncpy(name, m->u.match->name, sizeof(name));
> +	if (copy_to_user(hlp, name, EBT_FUNCTION_MAXNAMELEN))
>  		return -EFAULT;

strncpy() is very rarely the function you are looking for.
In this case it MIGHT be right (since you do a fixed size
copy_to_user).
OTOH there is no need to also initialise name[].
And it isn't entirely clear whether the application
is allowed to be given a non-terminated string.

	David
