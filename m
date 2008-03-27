From: "Denis V. Lunev" <den@openvz.org>
Subject: Re: SCTP control socket question
Date: Thu, 27 Mar 2008 16:09:58 +0300
Message-ID: <1206623398.32459.19.camel@iris.sw.ru>
References: <1206619433.32459.9.camel@iris.sw.ru>  <47EB9794.7010407@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev List <netdev@vger.kernel.org>,
	lksctp-developers@lists.sourceforge.net
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:4033 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760532AbYC0NJj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 09:09:39 -0400
In-Reply-To: <47EB9794.7010407@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-03-27 at 08:48 -0400, Vlad Yasevich wrote:
> Denis V. Lunev wrote:
> > Hello, Vlad!
> > 
> > I have read SCTP sources and found that SCTP control socket
> > (sctp_ctl_socket) remains hashed unlike similar staff in UDP/TCP etc.
> > 
> > Am I wrong, that it should not be hashed or not?
> 
> Why do you believe that the socket is hashed?  That socket is only
> allocated and referenced.  It's should not be in any hash tables
> since we hold a global reference on it.

sctp_ctl_sock_init
  __sock_create
    inet(6)_create
        sk->sk_prot->hash(sk);

For this purpose sk->sk_prot->unhash is explicitly called for ICMP/TCP
etc cases.

Regards,
	Den

