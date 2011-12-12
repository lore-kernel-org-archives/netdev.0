From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH 0/4] SUNRPC: pass network namespace context to sockaddr
 construction routines
Date: Mon, 12 Dec 2011 20:27:36 +0400
Message-ID: <4EE62B78.9030000@parallels.com>
References: <20111207111716.17273.63010.stgit@localhost6.localdomain6> <20111208204648.GB32505@fieldses.org> <4EE62824.9090807@parallels.com> <20111212161542.GH18185@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Pavel Emelianov <xemul@parallels.com>,
	"neilb@suse.de" <neilb@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	James Bottomley <jbottomley@parallels.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"devel@openvz.org" <devel@openvz.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111212161542.GH18185@fieldses.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

12.12.2011 20:15, J. Bruce Fields =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Mon, Dec 12, 2011 at 08:13:24PM +0400, Stanislav Kinsbursky wrote:
>> 09.12.2011 00:46, J. Bruce Fields =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>> On Wed, Dec 07, 2011 at 03:20:07PM +0300, Stanislav Kinsbursky wrot=
e:
>>>> This is another precursor patch set aimed to remove hard-coded "in=
it_net"
>>>> reference from SUNRPC sockaddr convertion and construction routine=
s.
>>>
>>> ACK--all look straightforward.  (Only complaint would be that this =
isn't
>>> terribly interesting till we see how these are used.)
>>>
>>
>> Actually, all is simple. These init_net pointers will be replaced
>> later by "transports, clients and others" network namespace
>> contexts.
>> I have some more patches for NFS layer. But I don't see any sense to
>> sent them now since no "virtualization" patches were commited yet.
>> So, currently, I'm trying to finalize "SUNRPC per network namespace"
>> task, and soon I'll send a patch set making SUNRPC sysctl's
>> network-namespace-aware. It is a little bit tricky and ugly from my
>> pow, so any ideas are welcome.
>
> No ideas.... What's the ugly part?
>
> --b.

I have some "id=C3=A9e fixe", that all this file system parts of SUNRPC=
 (and NFS)=20
layers have to made per network namespace context in the same manner as=
 sysfs=20
done. I.e. it's content should depends on mount point creator network n=
amespace=20
context instead of "current" one.
But proc (and sysctl's as well) doesn't allow to make it so simple like=
 sysfs does.
So, currently sysctl's code is about 30 lines. With my patches in will =
be=20
approximately 3-4 times longer.
But this "dependence on mount point creator network namespace" goal is =
achieved.
Anyway, I'll cleanup this code and send path set soon.


--=20
Best regards,
Stanislav Kinsbursky
