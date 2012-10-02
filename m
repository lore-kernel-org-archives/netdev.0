From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: network namespace and kernel bind issue
Date: Tue, 2 Oct 2012 08:51:28 -0700
Message-ID: <20121002085128.53251583@nehalam.linuxnetplumber.net>
References: <20121001141609.14639bc0@nehalam.linuxnetplumber.net>
	<20121001145838.5eafef4c@nehalam.linuxnetplumber.net>
	<87fw5xeryf.fsf@xmission.com>
	<20121001155702.5b5e2188@nehalam.linuxnetplumber.net>
	<87y5jpdbzo.fsf@xmission.com>
	<20121001163226.3873ca58@nehalam.linuxnetplumber.net>
	<871uhhd82p.fsf@xmission.com>
	<20121001174841.41fcd637@s6510.linuxnetplumber.net>
	<alpine.LFD.2.00.1210020910010.1642@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>, James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34838 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754729Ab2JBPwD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2012 11:52:03 -0400
In-Reply-To: <alpine.LFD.2.00.1210020910010.1642@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2 Oct 2012 09:15:46 +0300 (EEST)
Julian Anastasov <ja@ssi.bg> wrote:

> 
> 	Hello,
> 
> On Mon, 1 Oct 2012, Stephen Hemminger wrote:
> 
> > The problem was vxlan wasn't doing sk_change_net on the created socket.
> > 
> > I'm testing that fix.
> > 
> > The long term fix is to change sock_create_kern() to take a 'struct net'
> > argument. This would avoid the trap of having to change the namespace.
> > Also several places using __sock_create() could use it.
> > 
> > L2TP still looks to have several namespace related issues.
> 
> 	There should be also .netnsok = true in l2tp_nl_family
> as final step.
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>

There are actually lots more net namespace issues in L2TP.
For example session and tunnel counts are global, not per namespace.
