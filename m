From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH v4 1/8] SUNRPC: introduce helpers for reference counted
 rpcbind clients
Date: Tue, 20 Sep 2011 18:35:27 +0400
Message-ID: <4E78A4AF.1020303@parallels.com>
References: <20110920101031.9861.18444.stgit@localhost6.localdomain6> <20110920101341.9861.51453.stgit@localhost6.localdomain6> <4E788F8C.20103@netapp.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B47FD10@SACMVEXC2-PRD.hq.netapp.com> <4E789679.1060601@parallels.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B47FD22@SACMVEXC2-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Pavel Emelianov <xemul@parallels.com>,
	"neilb@suse.de" <neilb@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"bfields@fieldses.org" <bfields@fieldses.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B47FD22@SACMVEXC2-PRD.hq.netapp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

20.09.2011 18:14, Myklebust, Trond =D0=BF=D0=B8=D1=88=D0=B5=D1=82:

>>>
>>> Doesn't it  need to be protected by rpcb_clnt_lock too?
>>>
>>
>> Nope from my pow. It's protected by rpcb_create_local_mutex. I.e. no=
 one
>> will change rpcb_users since it's zero. If it's non zero - we willn'=
t get to
>> rpcb_set_local().
>
> OK, so you are saying that the rpcb_users++ below could be replaced b=
y rpcb_users=3D1?
>

Yes, you right.

> In that case, don't you need a smp_wmb() between the setting of rpcb_=
local_clnt/4 and the setting of rpcb_users? Otherwise, how do you guara=
ntee that rpcb_users !=3D 0 implies rpbc_local_clnt/4 !=3D NULL?
>

We check rpcb_users under spinlock. Gain spinlock forces memory barrier=
, doesn't it?

--=20
Best regards,
Stanislav Kinsbursky
