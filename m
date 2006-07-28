From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 2/7] NetLabel: core network changes
Date: Fri, 28 Jul 2006 14:45:53 -0400
Message-ID: <44CA5B61.3010704@hp.com>
References: <20060717155224.060020000@hp.com>	<20060717155822.315389000@hp.com> <20060728.005542.21593420.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, sds@epoch.ncsc.mil,
	jmorris@redhat.com, pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:36507 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S1752057AbWG1Sp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2006 14:45:57 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060728.005542.21593420.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: paul.moore@hp.com
> Date: Mon, 17 Jul 2006 11:52:26 -0400
>>@@ -617,6 +618,8 @@ int inet_accept(struct socket *sock, str
>> 
>> 	sock_graft(sk2, newsock);
>> 
>>+	netlbl_socket_inet_accept(sock, newsock);
>>+
>> 	newsock->state = SS_CONNECTED;
>> 	err = 0;
>> 	release_sock(sk2);
> 
> This is only true wart I see in the patch set from my
> perspective.
> 
> You have security_post_accept_hook(), which gets the parent and
> the child socket which is all the information you need, and it
> seems to be invoked at the correct location.
> 
> So can you please hook into this location using the security
> level hook we already have?  Just check sock->sk->sk_family is
> PF_INET at the top of that hook if you only want to handle
> ipv4 sockets, or something like that.
> 
> Could this work?
> 
> When preparing and argument stating why this won't work, please
> suggest a nicer name for this af_inet.c hook or some way to make
> it more generic and palatable to us.

The only reason for having this new hook in inet_accept() is to catch
all the in-kernel "daemons" who do not go through the LSM hooked
accept() code path.  I debated putting this hook into the patchset and
in the end figured it was at least worth a shot.

I'm happy to drop this hook as it *looks* like the MLSXFRM patchset is
going to make it which has some of the accept hooks I was hoping to get,
but figured I stood a "snowballs chance in hell" trying to get it in
solely for use with CIPSO :)  I'll drop this on the next release of the
NetLabel patchset and assuming both the NetLabel and the MLSXFRM
patchset make it into the 2.6.19 release I'll issue another small
patchset then to integrate into the new LSM hooks for accept.  I'd do it
now but I think it would cause too much of a mess with patch
dependencies/collisions/etc.

>>-		case 0x86:	/* Another "Commercial Security" crap. */
>>+		case IPOPT_CIPSO:
> 
> I am sad to see this comment disappear :-)

... and I was surprised you didn't comment about that change sooner ;)

-- 
paul moore
linux security @ hp
