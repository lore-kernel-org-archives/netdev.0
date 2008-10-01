From: "Denis V. Lunev" <den@openvz.org>
Subject: Re: [PATCH net-next] [RFC] netns: enable cross-ve Unix sockets
Date: Wed, 01 Oct 2008 15:32:56 +0400
Message-ID: <1222860776.23573.49.camel@iris.sw.ru>
References: <1222858454-7843-1-git-send-email-den@openvz.org>
	 <48E35B4C.1040303@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: containers@lists.linux-foundation.org, xemul@openvz.org,
	netdev@vger.kernel.org, benjamin.thery@bull.net,
	ebiederm@xmission.com
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:6778 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752315AbYJALey (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2008 07:34:54 -0400
In-Reply-To: <48E35B4C.1040303@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-10-01 at 13:13 +0200, Daniel Lezcano wrote:
> Denis V. Lunev wrote:
> > This patch opens a way to connect via Unix socket from one namespace
> > to another if these sockets are opened via conventional filesystem
> > interface. Such approach allows to share important services between
> > namespaces in efficient way.
> > 
> > This breach is controlled by the means of shared filesystem, i.e. if
> > somebody really wants to isolate containers, he should start from
> > filesystem separation.
> > 
> > Signed-off-by: Denis V. Lunev <den@openvz.org>
> > ---
> >  net/unix/af_unix.c |    3 ---
> >  1 files changed, 0 insertions(+), 3 deletions(-)
> > 
> > diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> > index 39d2173..0e1eccd 100644
> > --- a/net/unix/af_unix.c
> > +++ b/net/unix/af_unix.c
> > @@ -297,9 +297,6 @@ static struct sock *unix_find_socket_byinode(struct net *net, struct inode *i)
> >  		    &unix_socket_table[i->i_ino & (UNIX_HASH_SIZE - 1)]) {
> >  		struct dentry *dentry = unix_sk(s)->dentry;
> > 
> > -		if (!net_eq(sock_net(s), net))
> > -			continue;
> > -
> >  		if(dentry && dentry->d_inode == i)
> >  		{
> >  			sock_hold(s);
> 
> Hi Denis,
> 
> Do you have a list of the important services this isolation forbids ? (I 
> suppose there is syslog).

we have asked from our customers for a shared MySQL server

The full story is here :)
http://bugzilla.openvz.org/show_bug.cgi?id=985

