From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: BUG: scheduling while atomic: ifconfig/0x00000002/4170
Date: Thu, 6 Sep 2007 16:23:01 +0800
Message-ID: <20070906082301.GB21929@gondor.apana.org.au>
References: <20070902184439.GA14306@paradigm.rfc822.org> <6bffcb0e0709021659o3856cd06gabc054c949a84397@mail.gmail.com> <alpine.LFD.0.999.0709060923340.26804@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Lohoff <flo-BCn6idZOOBwdnm+yROfE0A@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Michal Piotrowski <michal.k.k.piotrowski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	ipw3945-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Satyam Sharma <satyam-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0709060923340.26804-cF9xTIDbLT5E1qDFBaZ7QYsk13R+tSIrn9A1Ff6Mc9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 06, 2007 at 10:32:33AM +0530, Satyam Sharma wrote:
> 
> > > [  382.529041]  [<c02c8abc>] dev_close+0x24/0x67
> > > [  382.529052]  [<e01f402b>] ieee80211_master_stop+0x4a/0x6d [mac80211]

This is where the bug is.  You cannot call dev_close from an
atomic context as i33380211_master_stop does it within spin
locks.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
