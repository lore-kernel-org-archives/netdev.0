From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/3] netfilter: Fix copy_to_user too small size
 parametre.
Date: Thu, 1 Mar 2012 14:03:11 +0100
Message-ID: <20120301130311.GA7429@1984>
References: <1330593390-19233-1-git-send-email-santoshprasadnayak@gmail.com>
 <20120301101809.GA6488@1984>
 <CAOD=uF6yqCETUG8jMCmjYDM+L1DsM91OiRveONJkNxMf=skTSg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bart.de.schuymer@pandora.be, kaber@trash.net,
	shemminger@vyatta.com, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	Dan Carpenter <dan.carpenter@oracle.com>
To: santosh prasad nayak <santoshprasadnayak@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36434 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030771Ab2CANDR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2012 08:03:17 -0500
Content-Disposition: inline
In-Reply-To: <CAOD=uF6yqCETUG8jMCmjYDM+L1DsM91OiRveONJkNxMf=skTSg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 01, 2012 at 04:15:05PM +0530, santosh prasad nayak wrote:
> Hi Pablo.
> 
> copy_to_user( dest, source, length)
> 
> Normally,  'length'  is equal to  'sizeof (source) '.
> 
> In this case "length"   =   32
>        "sizeof(source)"  =   29.
> 
> Is it intentional ?

ebtables expects 32 bytes names.

> Won't it copy extra 3 bytes of kernel data to userspace ?

You're right. We have to copy 29 bytes but we have to fill the
remaining bytes with zeroes. I think something like:

char name[EBT_FUNCTION_MAXNAMELEN] = {};

/* user-space ebtables expects 32 bytes-long names, but xt_match uses
 * 29 bytes for that. */
sprintf(name, "%s", m->u.match->name);
if (copy_to_user(hlp, name, EBT_FUNCTION_MAXNAMELEN))
...

will resolve this issue.

Would you resend a new patch?
