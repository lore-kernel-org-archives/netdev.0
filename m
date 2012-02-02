From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [RFC PATCH V4 02/13] netback: add module unload function.
Date: Thu, 2 Feb 2012 19:59:21 +0000
Message-ID: <1328212761.28964.77.camel@dagon.hellion.org.uk>
References: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
	 <1328201363-13915-3-git-send-email-wei.liu2@citrix.com>
	 <1328202524.11534.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1328203710.5553.94.camel@leeds.uk.xensource.com>
	 <1328204936.13262.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Wei Liu (Intern)" <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:62927 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932506Ab2BBT7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 14:59:23 -0500
In-Reply-To: <1328204936.13262.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-02-02 at 17:48 +0000, Eric Dumazet wrote:
> Le jeudi 02 f=E9vrier 2012 =E0 17:28 +0000, Wei Liu a =E9crit :
>=20
> > You're right about this.
> >=20
> > But this part is destined to get wiped out (in the very near future=
?) --
> > see following patches. So I don't think it is worthy to fix this.
> >=20
>=20
> Before adding new bugs, you must fix previous ones.

I've never heard of this requirement before! It's a wonder anyone ever
gets anything done.

Anyway, I think it would be reasonable to just remove the kthread_bind
call from this loop. We don't actually want/need a thread per online CP=
U
in any strict sense, we just want there to be some number of worker
threads available and ~numcpus at start of day is a good enough
approximation for that number. There have been patches floating around
in the past which make the number of groups a module parameter which
would also be a reasonable thing to dig out if we weren't just about to
remove all this code anyway.

So removing the kthread_bind is good enough for the short term, and for
stable if people feel that is necessary, and we can continue in mainlin=
e
with the direction Wei's patches are taking us.

Ian.
