From: jamal <hadi@cyberus.ca>
Subject: Re: [DOC]: generic netlink
Date: Tue, 20 Jun 2006 08:59:53 -0400
Message-ID: <1150808393.5172.13.camel@jzny2>
References: <1150724482.5815.48.camel@jzny2>
	 <Pine.LNX.4.64.0606191057420.21114@d.namei>
	 <1150730884.5384.10.camel@jzny2>
	 <Pine.LNX.4.64.0606191143540.21525@d.namei>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>, Jay Lan <jlan@engr.sgi.com>,
	Shailabh Nagar <nagar@watson.ibm.com>,
	Per Liden <per.liden@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:45697 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1750737AbWFTM77
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 08:59:59 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1Fsfpp-0005a9-3u
	for netdev@vger.kernel.org; Tue, 20 Jun 2006 09:00:01 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0606191143540.21525@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-19-06 at 11:54 -0400, James Morris wrote:
> On Mon, 19 Jun 2006, jamal wrote:
> 
> > Other that TIPC the two other users i have seen use it in this manner.
> > But, you are right if usage tends to lean in some other way we could get
> > rid of it (I think TIPC is a bad example).
> 
> Ok, perhaps make a note in the docs about this and keep an eye out when 
> new code is submitted, and encourage people not to do this.

Will do.

> Actually, what would help SELinux is the opposite, forcing everyone to use 
> separate commands and assigning security attributes to each one.  But 
> because TIPC is already multiplexing, it's not feasible.
> 

Then i would say they loose the fine level granularity that would have
otherwise been provided to them. Unless you are saying that choice is
not for them to make?

> Instead, I think the way to go for SELinux is to have each nl family 
> provide a permission callback, so SELinux can pass the skb back to the nl 
> module which then returns a type of permission ('read', 'write', 
> 'readpriv').  This way, the nl module can create and manage its own 
> internal table of command permissions and also know exactly where in the 
> message to dig for the command specifier.
> 

makes sense.

> > My view: If you want to have ACLs against such commands then it becomes 
> > easier to say "can only do ADD but not DEL" for example (We need to 
> > resolve genl_rcv_msg() check on commands to be in sync with SELinux as 
> > was pointed by Thomas)
> 
> This already exists, to some extent, but only for some protocols. You can 
> see examples of existing permission tables managed by SELinux in:
>  security/selinux/nlmsgtab.c
> 
> The hope move this out of SELinux and into each nl module, which is much 
> more manageable and scalable.

agreed.

cheers,
jamal


