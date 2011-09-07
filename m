From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: Re: [PATCH -next v2] unix stream: Fix use-after-free crashes
Date: Wed, 07 Sep 2011 14:15:15 -0700
Message-ID: <1315430115.2361.11.camel@schen9-mobl>
References: <4E631032.6050606@intel.com>
	 <1315326326.2576.2980.camel@schen9-DESK>
	 <1315330805.2899.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1315335019.2576.3048.camel@schen9-DESK>
	 <1315335660.3400.7.camel@edumazet-laptop>
	 <1315337580.2576.3066.camel@schen9-DESK>
	 <1315338186.3400.20.camel@edumazet-laptop>
	 <1315339157.2576.3079.camel@schen9-DESK>
	 <1315340388.3400.28.camel@edumazet-laptop>
	 <CAAM7YAn0c0SpAD42PcT+-HDXjT9HMajhmfZD6D68_0E21i2tSQ@mail.gmail.com>
	 <1315372100.3400.76.camel@edumazet-laptop> <4E66FF38.9000107@intel.com>
	 <1315381503.3400.85.camel@edumazet-laptop>
	 <1315396903.2364.23.camel@schen9-mobl>
	 <CA+icZUVqJVn4ONuSDV5YdgpEcmetVMM9X=Sxt2EqM8qdegMnjQ@mail.gmail.com>
	 <CA+icZUW5Biu8cMhaJcz=MwtMOVn-NFD92PTpT0-DfEDKrRmaUQ@mail.gmail.com>
	 <1315406256.6287.7.camel@schen9-mobl>  <4E680BF1.8000901@intel.com>
	 <1315429583.2361.3.camel@schen9-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "sedat.dilek@gmail.com" <sedat.dilek@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Yan, Zheng" <yanzheng@21cn.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"jirislaby@gmail.com" <jirislaby@gmail.com>,
	"Shi, Alex" <alex.shi@intel.com>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	"Yan, Zheng" <zheng.z.yan@intel.com>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:3553 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750902Ab1IHEPR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Sep 2011 00:15:17 -0400
In-Reply-To: <1315429583.2361.3.camel@schen9-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-09-07 at 14:06 -0700, Tim Chen wrote:
> On Thu, 2011-09-08 at 08:27 +0800, Yan, Zheng wrote:
> 
> > >  	err = -EPIPE;
> > >  out_err:
> > > -	if (skb == NULL)
> > > +	if (!steal_refs)
> > >  		scm_destroy(siocb->scm);
> > 
> > I think we should call scm_release() here in the case of
> > steal_refs == true. Otherwise siocb->scm->fp may leak.
> 
> Yan Zheng,
> 
> I've updated the patch.  If it looks good to you now, can you add your
> Signed-off-by to the patch.  Pending Sedat's testing on this patch,
> I think it is good to go.
> 
> Tim

Oops, I've forgotten to add Eric's previous Signed-off-by in my latest
patch log.  David, please add that when you pick up the patch.  
Once Yan Zheng added his sign off and Sedat tested the patch, I think it
will be good to go.

Thanks.

Tim 
