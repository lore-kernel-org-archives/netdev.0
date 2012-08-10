From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [RFC PATCH 0/2] net: connect to UNIX sockets from specified root
Date: Fri, 10 Aug 2012 22:50:48 +0400
Message-ID: <50255808.6080208@parallels.com>
References: <20120810125701.7115.71612.stgit@localhost.localdomain> <50254FA6.3060806@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	Pavel Emelianov <xemul@parallels.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"bfields@fieldses.org" <bfields@fieldses.org>,
	"viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"tim.c.chen@linux.intel.com" <tim.c.chen@linux.intel.com>,
	"devel@openvz.org" <devel@openvz.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50254FA6.3060806@zytor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

10.08.2012 22:15, H. Peter Anvin =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On 08/10/2012 05:57 AM, Stanislav Kinsbursky wrote:
>> Today, there is a problem in connecting of local SUNRPC thansports. =
These
>> transports uses UNIX sockets and connection itself is done by rpciod
>> workqueue.
>> But UNIX sockets lookup is done in context of process file system ro=
ot. I.e.
>> all local thunsports are connecting in rpciod context.
>> This works nice until we will try to mount NFS from process with oth=
er root -
>> for example in container. This container can have it's own (nested) =
root and
>> rcpbind process, listening on it's own unix sockets. But NFS mount a=
ttempt in
>> this container will register new service (Lockd for example) in glob=
al rpcbind
>> - not containers's one.
>>
>> This patch set introduces kernel connect helper for UNIX stream sock=
ets and
>> modifies unix_find_other() to be able to search from specified root.
>> It also replaces generic socket connect call for local transports by=
 new
>> helper in SUNRPC layer.
>>
>> The following series implements...
> On that whole subject...
>
> Do we need a Unix domain socket equivalent to openat()?

It looks like sys_connectat () and sys_bindat () could be an organic=20
part on openat () and friends family.
But currently I don't have any usage example for them in hands.  And th=
e=20
main problem here, that this syscalls can be used only for unix sockets=
=2E
