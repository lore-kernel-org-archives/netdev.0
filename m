From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [RFC PATCH] SUNRPC: connect local transports synchronously
Date: Fri, 17 Feb 2012 12:25:45 +0400
Message-ID: <4F3E0F09.8020200@parallels.com>
References: <20120216150507.19081.28659.stgit@localhost6.localdomain6> <1329405232.4279.4.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Pavel Emelianov <xemul@parallels.com>,
	"neilb@suse.de" <neilb@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	James Bottomley <jbottomley@parallels.com>,
	"bfields@fieldses.org" <bfields@fieldses.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"devel@openvz.org" <devel@openvz.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329405232.4279.4.camel@lade.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

16.02.2012 19:13, Myklebust, Trond =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Thu, 2012-02-16 at 19:06 +0400, Stanislav Kinsbursky wrote:
>> Local tranports uses UNIX sockets and connecting of these sockets is=
 done in
>> context of file system namespace (i.e. task file system root).
>> Currenly, all sockets connect operations are performed by rpciod wor=
k queue,
>> which actually means, that any service will be registered in the sam=
e rpcbind
>> instance regardless to process file system root.
>> This is not containers, which usually have it's own nested root. The=
re are 2
>> approaches, how to solve the problem. First one is to store proper r=
oot in
>> tranport and switch to it in rpciod workqueue function for connect o=
perations.
>> But this looks ugly. The second one is to connect to unix sockets
>> synchronously. This aptch implements the last one.
>
> That approach can fall afoul of the selinux restrictions on the proce=
ss
> context. Processes that are allowed to write data, may not be allowed=
 to
> create sockets or call connect(). That is the main reason for doing i=
t
> in the rpciod context, which is a clean kernel process context.
>

Thanks for explanation, Trond.
So, this connect have to be done in kernel process context.
Now I can see 2 ways how to meet this requirement and reach the goal:

1) Change the fs root for rpciod while connecting.
2) Do not touch rpciod and launch special "connect" kernel thread to pe=
rform=20
connect operations for unix sockets.

What do you think about this 2 ways above? Which one is less worse from=
 your POW?
Maybe you have even a better solution for the problem?

--=20
Best regards,
Stanislav Kinsbursky
