From: Xiaolan Zhang <cxzhang@us.ibm.com>
Subject: Re: [PATCH] scm: fold __scm_send() into scm_send()
Date: Thu, 6 Apr 2006 13:52:48 -0400
Message-ID: <OFD873D233.5BCDC487-ON85257148.0061E542-85257148.00623838@us.ibm.com>
References: <1142948528.28120.34.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Andrew Morton <akpm@osdl.org>, Chris Wright <chrisw@sous-sol.org>,
	cxzhang@watson.ibm.com, davem@davemloft.net, ioe-lkml@rameria.de,
	James Morris <jmorris@namei.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netdev@axxeo.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751302AbWDFRxa@vger.kernel.org>
In-Reply-To: <1142948528.28120.34.camel@moss-spartans.epoch.ncsc.mil>
To: sds@tycho.nsa.gov
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Stephen and James,

Looks like the selinux_sk_ctxid() call implemented in James' patch also 
requires the sk_callback_lock (see below).  I am planning to introduce a 
new exported fucntion selinux_sock_ctxid() which does not require any 
locking.  Comments?

thanks,
Catherine

Stephen Smalley <sds@tycho.nsa.gov> wrote on 03/21/2006 08:42:08 AM:

> On Tue, 2006-03-21 at 08:32 -0500, Stephen Smalley wrote:
> > > I don't expect security_sk_sid() to be terribly expensive.  It's not
> > > an AVC check, it's just propagating a label.  But I've not done any
> > > benchmarking on that.
> > 
> > No permission check there, but it looks like it does read lock
> > sk_callback_lock.  Not sure if that is truly justified here.
> 
> Ah, that is because it is also called from the xfrm code, introduced by
> Trent's patches.  But that locking shouldn't be necessary from scm_send,
> right?  So she likely wants a separate hook for it to avoid that
> overhead, or even just a direct SELinux interface?
> 
> -- 
> Stephen Smalley
> National Security Agency
> 
