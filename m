From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: SCTP control socket question
Date: Thu, 27 Mar 2008 09:15:55 -0400
Message-ID: <47EB9E0B.2030400@hp.com>
References: <1206619433.32459.9.camel@iris.sw.ru>  <47EB9794.7010407@hp.com> <1206623398.32459.19.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev List <netdev@vger.kernel.org>,
	lksctp-developers@lists.sourceforge.net
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:45490 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759696AbYC0NP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 09:15:58 -0400
In-Reply-To: <1206623398.32459.19.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denis V. Lunev wrote:
> On Thu, 2008-03-27 at 08:48 -0400, Vlad Yasevich wrote:
>> Denis V. Lunev wrote:
>>> Hello, Vlad!
>>>
>>> I have read SCTP sources and found that SCTP control socket
>>> (sctp_ctl_socket) remains hashed unlike similar staff in UDP/TCP etc.
>>>
>>> Am I wrong, that it should not be hashed or not?
>> Why do you believe that the socket is hashed?  That socket is only
>> allocated and referenced.  It's should not be in any hash tables
>> since we hold a global reference on it.
> 
> sctp_ctl_sock_init
>   __sock_create
>     inet(6)_create
>         sk->sk_prot->hash(sk);
> 
> For this purpose sk->sk_prot->unhash is explicitly called for ICMP/TCP
> etc cases.
> 
> Regards,
> 	Den
> 

Ahhh...  ;-)

struct proto sctp_prot = {
...
	.hash        =  sctp_hash,
...
}

static void sctp_hash(struct sock *sk)
{
        /* STUB */
}


SCTP currently does't do any hashing on the sockets.  It hashes SCTP structures
that live under the socket.

Regards
-vlad
