From: James Morris <jmorris@namei.org>
Subject: Re: [DOC]: generic netlink
Date: Mon, 19 Jun 2006 11:54:07 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0606191143540.21525@d.namei>
References: <1150724482.5815.48.camel@jzny2>  <Pine.LNX.4.64.0606191057420.21114@d.namei>
 <1150730884.5384.10.camel@jzny2>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Per Liden <per.liden@ericsson.com>,
	Shailabh Nagar <nagar@watson.ibm.com>,
	Jay Lan <jlan@engr.sgi.com>, Thomas Graf <tgraf@suug.ch>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.sea5.speakeasy.net ([69.17.117.4]:6553 "EHLO
	mail2.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932214AbWFSPyK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jun 2006 11:54:10 -0400
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1150730884.5384.10.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 19 Jun 2006, jamal wrote:

> Other that TIPC the two other users i have seen use it in this manner.
> But, you are right if usage tends to lean in some other way we could get
> rid of it (I think TIPC is a bad example).

Ok, perhaps make a note in the docs about this and keep an eye out when 
new code is submitted, and encourage people not to do this.

> > This would both simplify the genl code and API, and help ensure 
> > consistency of users.
> > 
> 
> You are talking from an SELinux perspective i take it?

Actually, what would help SELinux is the opposite, forcing everyone to use 
separate commands and assigning security attributes to each one.  But 
because TIPC is already multiplexing, it's not feasible.

Instead, I think the way to go for SELinux is to have each nl family 
provide a permission callback, so SELinux can pass the skb back to the nl 
module which then returns a type of permission ('read', 'write', 
'readpriv').  This way, the nl module can create and manage its own 
internal table of command permissions and also know exactly where in the 
message to dig for the command specifier.

> My view: If you want to have ACLs against such commands then it becomes 
> easier to say "can only do ADD but not DEL" for example (We need to 
> resolve genl_rcv_msg() check on commands to be in sync with SELinux as 
> was pointed by Thomas)

This already exists, to some extent, but only for some protocols. You can 
see examples of existing permission tables managed by SELinux in:
 security/selinux/nlmsgtab.c

The hope move this out of SELinux and into each nl module, which is much 
more manageable and scalable.


- James
-- 
James Morris
<jmorris@namei.org>
