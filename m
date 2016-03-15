From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] af_unix: closed SOCK_SEQPACKET socketpair must get
 SIGPIPE
Date: Tue, 15 Mar 2016 13:46:11 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D4111FC91@AcuExch.aculab.com>
References: <1458032624-139688-1-git-send-email-glider@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Alexander Potapenko' <glider@google.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"rweikusat@mobileactivedefense.com"
	<rweikusat@mobileactivedefense.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458032624-139688-1-git-send-email-glider@google.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Potapenko
> Sent: 15 March 2016 09:04
> According to IEEE Std 1003.1, 2013, sending data to a SOCK_SEQPACKET
> socketpair with MSG_NOSIGNAL flag set must result in a SIGPIPE if the
> socket is no longer connected.
...
> Without the below patch the behavior is as follows:
> 
> $ ./sock seqpacket
> sendmsg: Broken pipe
...
> The behavior of the patched kernel complies with POSIX:
> 
> $  ./sock seqpacket
> Killed by SIGPIPE
...

While POSIX might specify this behaviour, changing the behaviour
could easily break applications.
Basically this change (more or less) require every application that
uses SOCK_SEQPACKED to be audited to ensure that MSG_NOSIGNAL is set
on ever send/write to the socket.

Personally I think the whole SIGPIPE on sockets should never have been
allowed to get into the standard.
I don't remember MSG_NOSIGNAL being present in SYSV.

The only time you want a write into a pipe to generate SIGPIPE is
for pipes generates by the shell that feed stdout to stdin of the
next process in the pipeline.
If pipes are implemented as unix-domain socketpairs (no one does that
any more) then it would require the SIGPIPE for write().

	David
