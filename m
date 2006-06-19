From: jamal <hadi@cyberus.ca>
Subject: Re: [DOC]: generic netlink
Date: Mon, 19 Jun 2006 11:28:04 -0400
Message-ID: <1150730884.5384.10.camel@jzny2>
References: <1150724482.5815.48.camel@jzny2>
	 <Pine.LNX.4.64.0606191057420.21114@d.namei>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Per Liden <per.liden@ericsson.com>,
	Shailabh Nagar <nagar@watson.ibm.com>,
	Jay Lan <jlan@engr.sgi.com>, Thomas Graf <tgraf@suug.ch>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:147 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S932474AbWFSP2L
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jun 2006 11:28:11 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FsLfi-0003u3-O6
	for netdev@vger.kernel.org; Mon, 19 Jun 2006 11:28:14 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0606191057420.21114@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-19-06 at 11:13 -0400, James Morris wrote:

> 
> It seems that TIPC is multiplexing all of it's commands through  
> TIPC_GENL_CMD.


TIPC is a deviation; they had the 100 ioctls and therefore did a direct
one-to-one mapping.

> I wonder, if this is how other protocols are likely to utilize genl, then 
> we could possibly drop the command registration code completely and one 
> command op can be registered by the protocol during 
> genl_register_family().
> 

The intent is to have a handful of commands as in classical netlink
(eg route or qdisc etc) where you are controlling data that sits in the
kernel; i.e when you have an attribute or a vector of attributes, then
the commands will be of the semantics: ADD/DEL/GET/DUMP only. 
Other that TIPC the two other users i have seen use it in this manner.
But, you are right if usage tends to lean in some other way we could get
rid of it (I think TIPC is a bad example).

> This would both simplify the genl code and API, and help ensure 
> consistency of users.
> 

You are talking from an SELinux perspective i take it?
My view: If you want to have ACLs against such commands
then it becomes easier to say "can only do ADD but not DEL" for example
(We need to resolve genl_rcv_msg() check on commands to be in sync with
SELinux as was pointed by Thomas)

cheers,
jamal

