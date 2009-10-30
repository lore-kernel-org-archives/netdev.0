From: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
Subject: Re: [PATCH 2/8] param: use ops in struct kernel_param, rather than get and set fns directly
Date: Fri, 30 Oct 2009 21:43:39 +1030
Message-ID: <200910302143.40268.rusty@rustcorp.com.au>
References: <20091022142337.EC4A85362F@mx1.suse.de> <s5hvdhxyyl7.wl%tiwai@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ville Syrjala <syrjala-ORSVBvAovxo@public.gmane.org>,
	Dmitry Torokhov <dmitry.torokhov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Alessandro Rubini <rubini-JCs+bAQazDroPXhRcRtihA@public.gmane.org>,
	Michal Januszewski <spock-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>, linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-fbdev-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <s5hvdhxyyl7.wl%tiwai-l3A5Bk7waGM@public.gmane.org>
Content-Disposition: inline
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 30 Oct 2009 08:48:12 pm Takashi Iwai wrote:
> At Fri, 23 Oct 2009 00:51:28 +1030,
> Rusty Russell wrote:
> > 
> > This is more kernel-ish, saves some space, and also allows us to
> > expand the ops without breaking all the callers who are happy for the
> > new members to be NULL.
> > 
> > The few places which defined their own param types are changed to the
> > new scheme.
> > 
> > Since we're touching them anyway, we change get and set to take a
> > const struct kernel_param (which they were, and will be again).
> > 
> > To reduce churn, module_param_call creates the ops struct so the callers
> > don't have to change (and casts the functions to reduce warnings).
> > The modern version which takes an ops struct is called module_param_cb.
> 
> This is nice, as it also reduces the size of struct kernel_param, so
> each parameter uses less footprint (who cares, though?) :)
> 
> But, just wondering whether we still need to export get/set
> functions.  They can be called from ops now, so if any, it can be
> defined even as an inlinefunction or a macro.

My thought too, so I tried that, but many are still used like so:

	module_param_call(foo, set_foo, param_get_uint, NULL, 0644);

They can all be replaced in time with something like:
	static int param_get_foo(char *buffer, const struct kernel_param *kp)
	{
		return param_ops_uint.get(buffer, kp);
	}

But it'll take a transition period.

Thanks!
Rusty.



> 
> 
> thanks,
> 
> Takashi
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
