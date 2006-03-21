From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [PATCH] scm: fold __scm_send() into scm_send()
Date: Tue, 21 Mar 2006 08:42:08 -0500
Message-ID: <1142948528.28120.34.camel@moss-spartans.epoch.ncsc.mil>
References: <200603130139.k2D1dpSQ021279@shell0.pdx.osdl.net>
	 <200603132105.32794.ioe-lkml@rameria.de>
	 <20060313173103.7681b49d.akpm@osdl.org>
	 <200603201244.58507.netdev@axxeo.de>
	 <20060320201802.GS15997@sorel.sous-sol.org>
	 <20060320213636.GT15997@sorel.sous-sol.org>
	 <20060320143103.31b7d933.akpm@osdl.org>
	 <20060320231508.GV15997@sorel.sous-sol.org>
	 <1142947952.28120.29.camel@moss-spartans.epoch.ncsc.mil>
Reply-To: sds@tycho.nsa.gov
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: James Morris <jmorris@namei.org>, Andrew Morton <akpm@osdl.org>,
	cxzhang@watson.ibm.com, netdev@axxeo.de, ioe-lkml@rameria.de,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751707AbWCUNh2@vger.kernel.org>
To: Chris Wright <chrisw@sous-sol.org>
In-Reply-To: <1142947952.28120.29.camel@moss-spartans.epoch.ncsc.mil>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-03-21 at 08:32 -0500, Stephen Smalley wrote:
> > I don't expect security_sk_sid() to be terribly expensive.  It's not
> > an AVC check, it's just propagating a label.  But I've not done any
> > benchmarking on that.
> 
> No permission check there, but it looks like it does read lock
> sk_callback_lock.  Not sure if that is truly justified here.

Ah, that is because it is also called from the xfrm code, introduced by
Trent's patches.  But that locking shouldn't be necessary from scm_send,
right?  So she likely wants a separate hook for it to avoid that
overhead, or even just a direct SELinux interface?
  
-- 
Stephen Smalley
National Security Agency
