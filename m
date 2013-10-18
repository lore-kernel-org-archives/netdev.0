From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] net: unix: inherit SOCK_PASS{CRED,SEC} flags from socket to fix race
Date: Fri, 18 Oct 2013 09:26:11 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7395@saturn3.aculab.com>
References: <cover.1382042286.git.dborkman@redhat.com> <5c4eda258a6d7397a180ca72562b0ce5d87beda1.1382042286.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "Eric Dumazet" <edumazet@google.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: "Daniel Borkmann" <dborkman@redhat.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:54979 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751228Ab3JRI20 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 04:28:26 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 01123-02 for <netdev@vger.kernel.org>;
 Fri, 18 Oct 2013 09:28:21 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <5c4eda258a6d7397a180ca72562b0ce5d87beda1.1382042286.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Subject: [PATCH net] net: unix: inherit SOCK_PASS{CRED,SEC} flags from socket to fix race
> 
> In the case of credentials passing in unix stream sockets (dgram
> sockets seem not affected), we get a rather sparse race after
> commit 16e5726 ("af_unix: dont send SCM_CREDENTIALS by default").
...
> +static void unix_sock_inherit_flags(const struct socket *old,
> +				    struct socket *new)
> +{
> +	if (test_bit(SOCK_PASSCRED, &old->flags))
> +		set_bit(SOCK_PASSCRED, &new->flags);
> +	if (test_bit(SOCK_PASSSEC, &old->flags))
> +		set_bit(SOCK_PASSSEC, &new->flags);
> +}
> +

Isn't that just:
	new->flags |= old->flags & (PASSCRED | SOCK_PASSSEC);

	David
