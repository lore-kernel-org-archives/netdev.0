From: mcgrof@studorgs.rutgers.edu (Luis R. Rodriguez)
Subject: Re: Prism54 wpa update
Date: Wed, 30 Jun 2004 10:01:04 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040630140104.GD14482@ruslug.rutgers.edu>
References: <20040629192101.GB14482@ruslug.rutgers.edu> <20040629202210.GK23191@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@oss.sgi.com>, prism54-devel@prism54.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20040629202210.GK23191@havoc.gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jun 29, 2004 at 04:22:10PM -0400, Jeff Garzik wrote:
> On Tue, Jun 29, 2004 at 03:21:01PM -0400, Luis R. Rodriguez wrote:
> > 
> > I'll keep my latest wpa work/patch at the following URL:
> > 
> > http://prism54.org/~mcgrof/prism54-wpa.diff
> > 
> > I've nuked module params and am relying on private ioctls now since,
> > 
> > * we already have a [s|g]et_wpa priv iotcl, and
> > * in preperation for the WPA patch for Wireless Extensions.
> > 
> > I'll work on wpa ie scans tonight and try to fix mgt for
> > handling traps in extended mode. This is not related to wpa, but
> > I also made the firmware load at probe time. I turned the radio
> > off at probe after firmware load time too since the device is
> > not technically up yet.
> 
> Patch seems sane, though I vaguely recall xchg() not being atomic on all
> platforms (such as i386?).  Maybe I'm wrong, an expert should speak up :)

Just in case -- please don't apply the patch yet, I put it up as for review
and update as to where I am.

> I also worry that the following is a race, but I have not traced the
> code to verify or discount my guess:
> 
> +       u32 mlme, authen, dot1x, filter, wep;
> +
> +
> +       if (islpci_get_state(priv) < PRV_STATE_INIT)
> +               return 0;
>  
>         down_write(&priv->mib_sem);

FWIW, the context that this is within is prism54_set_wpa, a private ioctl. 

	Luis

-- 
GnuPG Key fingerprint = 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E
