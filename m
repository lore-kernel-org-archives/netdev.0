From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: updated [Patch 1/1] AF_UNIX Datagram getpeersec
Date: Fri, 16 Jun 2006 21:16:03 -0700
Message-ID: <20060616211603.14547a1d@localhost.localdomain>
References: <20060617035440.GA28169@jiayuguan.watson.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jmorris@redhat.com,
	chrisw@osdl.org, herbert@gondor.apana.org.au, sds@tycho.nsa.gov,
	tjaeger@cse.psu.edu, akpm@osdl.org, latten@austin.ibm.com,
	sergeh@us.ibm.com, gcwilson@us.ibm.com, czhang.us@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:26311 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751610AbWFQEQy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jun 2006 00:16:54 -0400
To: Catherine Zhang <cxzhang@watson.ibm.com>
In-Reply-To: <20060617035440.GA28169@jiayuguan.watson.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

O
>  
> +void selinux_get_sock_sid(const struct socket *sock, u32 *sid)
> +{
> +	if (selinux_enabled) {
> +		const struct inode *inode = SOCK_INODE(sock);
> +		selinux_get_inode_sid(inode, sid);
> +		return;
> +	}
> +	*sid = 0;
> +}
> +

This is so short, it would make sense to put it in scm.h
and why not have it return the value instead of call by reference?
Same goes for selinux_get_inode_sid

static inline void selinux_get_sock_sid(const struct socket *sock, u32 *sid)
{
	if (selinux_enabled)
		selinux_get_inode_sid(SOCK_INODE(sock), sid);
	else
		*sid = 0;
}

or
static inline u32 selinux_get_sock_sid(const struct socket *sock)
{
	return selinux_enabled ? selinux_get_inode_sid(SOCK_INODE(sid)) : 0;
}
