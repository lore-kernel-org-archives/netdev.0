From: Courtney Cavin <courtney.cavin-/MT0OVThwyLZJqsBc5GL+g@public.gmane.org>
Subject: Re: [PATCH] net: add Qualcomm IPC router
Date: Wed, 16 Dec 2015 16:01:41 -0800
Message-ID: <20151217000141.GG28026@sonymobile.com>
References: <1449866519-14551-1-git-send-email-bjorn.andersson@sonymobile.com>
 <20151215.160114.1178824607335349574.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Andersson, Bj?rn" <Bjorn.Andersson-/MT0OVThwyLZJqsBc5GL+g@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"srinivas.kandagatla-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org" <srinivas.kandagatla-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	"linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20151215.160114.1178824607335349574.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 15, 2015 at 10:01:14PM +0100, David Miller wrote:
> From: Bjorn Andersson <bjorn.andersson-/MT0OVThwyLZJqsBc5GL+g@public.gmane.org>
> Date: Fri, 11 Dec 2015 12:41:59 -0800
> 
> > +static unsigned int qrtr_local_nid = 1;
> > +module_param_named(node_id, qrtr_local_nid, uint, S_IRUGO);
> > +MODULE_PARM_DESC(idVendor, "Local Node Identifier");
> 
> Module parameters suck.
> 
> Allow the user to choose this dynamically.  You have roughtly two choices.
> 
> 1) Subvert the 'protocol' field passed to ->create() and use that, it is
>    being ignored otherwise.
> 
> 2) Put it into the socket address for bind().

So each socket can have its own node id?  That doesn't seem right.

The way these node ids are assigned is by a system designer (in this
case Qualcomm).  The ARM, Linux CPU is always node 1, the audio DSP is
always node 5, etc.  Anyone with the knowhow could reassign these
numbers, but there's no reason to have them be dynamic during runtime.
Additionally, allowing dynamic assignment would require code to prevent
id duplication for known remote nodes, as well as to deal with cases in
which remote node discovery happens after local sockets have acquired
that node's id.

Maybe the first socket created needs CAP_NET_ADMIN, and uses the
'protocol' field to set the node id?  Ugh. Gross.

We could hardcode the value in kconfig, but that seems like a worse
solution than a module parameter.

I'm open to further suggestions.

-Courtney
