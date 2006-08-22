From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [Lksctp-developers] [PATCH 3/5][SCTP]: Remove multiple levels of msecs to jiffies conversions.
Date: Tue, 22 Aug 2006 09:44:37 -0400
Message-ID: <200608220944.37254.vladislav.yasevich@hp.com>
References: <1155925357.20802.27.camel@w-sridhar2.beaverton.ibm.com> <20060822.002253.26973121.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, sri@us.ibm.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:55494 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S932239AbWHVNoj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2006 09:44:39 -0400
To: lksctp-developers@lists.sourceforge.net
In-Reply-To: <20060822.002253.26973121.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue August 22 2006 03:22, David Miller wrote:
> From: Sridhar Samudrala <sri@us.ibm.com>
> Date: Fri, 18 Aug 2006 11:22:37 -0700
>
> > [SCTP]: Remove multiple levels of msecs to jiffies conversions.
> >
> > The SCTP sysctl entries are displayed in milliseconds, but stored
> > internally in jiffies. This results in multiple levels of msecs to
> > jiffies conversion and as a result produces a truncation error. This
> > patch makes things consistent in that we store and display defaults
> > in milliseconds and only convert once for use by association.
> > This patch also adds some sane min/max values so that we don't go off
> > the deep end.
> >
> > Signed-off-by: Vladislav Yasevich <vladislav.yasevich@hp.com>
> > Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
>
> This cannot be done.
>
> The syctl values have a fixed format, like any other portion
> of the API exposed to userspace.
>
> So you cannot arbitrarily change the units to/from milliseconds
> and jiffies.

Dave

We are not changing the units exposed to the user.  We have used and
are still using  milliseconds to communicate with the user.  What this patch 
removes is the initial conversion of user milliseconds to kernel internal 
jiffies that are stored into the SCTP globabl variables.  SCTP uses these 
globals initialize per socket variables that are in milliseconds, so ended up 
doing a useless conversion back to ms to initialize these socket variables.  
During this conversion, we ended up with truncation error that this patch 
corrects.

Again, the variables exposed by the user interface have been and remain in 
milliseconds.

-vlad
>
> -------------------------------------------------------------------------
> Using Tomcat but need to do more? Need to support web services, security?
> Get stuff done quickly with pre-integrated technology to make your job
> easier Download IBM WebSphere Application Server v.1.0.1 based on Apache
> Geronimo
> http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
> _______________________________________________
> Lksctp-developers mailing list
> Lksctp-developers@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/lksctp-developers
