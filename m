From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [Outreachy kernel] Re: [PATCH 2/2] Staging: irda: Remove
 parentheses on the right of assignment
Date: Fri, 15 Sep 2017 23:50:29 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1709152348360.2533@hadrien>
References: <cover.1505508423.git.srishtishar@gmail.com>  <9380189edb2722544981c868699ade29ab5c297d.1505508423.git.srishtishar@gmail.com> <1505511108.27581.16.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Srishti Sharma <srishtishar@gmail.com>, samuel@sortiz.org,
        gregkh@linuxfoundation.org, netdev@vger.kernel.org,
        devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org,
        outreachy-kernel@googlegroups.com
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505511108.27581.16.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 15 Sep 2017, Joe Perches wrote:

> On Sat, 2017-09-16 at 02:36 +0530, Srishti Sharma wrote:
> > Parentheses are not needed on the right hand side of assignment
> > statement in most cases. Done using the following semantic
> > patch by coccinelle.
> []
> > @@
> > identifier E,F,G,f;
> > expression e,r;
> > @@
> >
> > (
> > E = (G == F);
> > >
> >
> > E = (e == r);
> > >
> >
> > E =
> > -(
> > ...
> > -)
> > ;
> > )
> []
> > diff --git a/drivers/staging/irda/drivers/mcs7780.c b/drivers/staging/irda/drivers/mcs7780.c
> []
> > @@ -605,7 +605,7 @@ static int mcs_speed_change(struct mcs_cb *mcs)
> >  	if (mcs->new_speed <= 115200) {
> >  		rval &= ~MCS_FIR;
> >
> > -		rst = (mcs->speed > 115200);
> > +		rst = mcs->speed > 115200;
> >  		if (rst)
> >  			mcs_set_reg(mcs, MCS_MINRXPW_REG, 0);
>
> Coccinelle is a good tool, but its output is limited to
> the correctness
> and completeness of its input script.
>
> Please look at the suggested modifications of the script
> and examine the code for other similar uses.
>
> The else if block immediately below this is:
>
> 	} else if (mcs->new_speed <= 1152000) {
> 		rval &= ~MCS_FIR;
>
> 		if ((rst = !(mcs->speed == 576000 || mcs->speed == 11520
> 00)))
> 			mcs_set_reg(mcs, MCS_MINRXPW_REG, 5);
>
> which should also be corrected by this patch.

You're concerned about the assignment in the if header?  Because that was
in 1/2.  One could also push the ! under the ||, but I'm not sure that
would be much of an improvement.

julia

>
> --
> You received this message because you are subscribed to the Google Groups "outreachy-kernel" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to outreachy-kernel+unsubscribe@googlegroups.com.
> To post to this group, send email to outreachy-kernel@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/outreachy-kernel/1505511108.27581.16.camel%40perches.com.
> For more options, visit https://groups.google.com/d/optout.
>
