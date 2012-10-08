From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [RFC PATCH 0/5] net: socket bind to file descriptor introduced
Date: Mon, 8 Oct 2012 12:37:51 +0400
Message-ID: <507290DF.30307@parallels.com>
References: <20120815161141.7598.16682.stgit@localhost.localdomain> <87y5lf7d37.fsf@xmission.com> <50320EE5.10307@parallels.com> <20120904190007.GB29369@fieldses.org> <20121005200009.GA30139@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"hpa@zytor.com" <hpa@zytor.com>,
	"thierry.reding@avionic-design.de" <thierry.reding@avionic-design.de>,
	"bfields@redhat.com" <bfields@redhat.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	Pavel Emelianov <xemul@parallels.com>,
	"neilb@suse.de" <neilb@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"x86@kernel.org" <x86@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"paul.gortmaker@windriver.com" <paul.gortmaker@windriver.com>,
	"viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"gorcunov@openvz.org" <gorcunov@openvz.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"tim.c.chen@linux.intel.com" <tim.c.chen@linux.intel.com>,
	"devel@ope
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121005200009.GA30139@fieldses.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

06.10.2012 00:00, J. Bruce Fields =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Tue, Sep 04, 2012 at 03:00:07PM -0400, bfields wrote:
>> On Mon, Aug 20, 2012 at 02:18:13PM +0400, Stanislav Kinsbursky wrote=
:
>>> 16.08.2012 07:03, Eric W. Biederman =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>>> Stanislav Kinsbursky <skinsbursky@parallels.com> writes:
>>>>
>>>>> This patch set introduces new socket operation and new system cal=
l:
>>>>> sys_fbind(), which allows to bind socket to opened file.
>>>>> File to bind to can be created by sys_mknod(S_IFSOCK) and opened =
by
>>>>> open(O_PATH).
>>>>>
>>>>> This system call is especially required for UNIX sockets, which h=
as name
>>>>> lenght limitation.
>>>>>
>>>>> The following series implements...
>>>>
>>>> Hmm.  I just realized this patchset is even sillier than I thought=
=2E
>>>>
>>>> Stanislav is the problem you are ultimately trying to solve nfs cl=
ients
>>>> in a container connecting to the wrong user space rpciod?
>>>>
>>>
>>> Hi, Eric.
>>> The problem you mentioned was the reason why I started to think abo=
ut this.
>>> But currently I believe, that limitations in unix sockets connect o=
r
>>> bind should be removed, because it will be useful it least for CRIU
>>> project.
>>>
>>>> Aka net/sunrpc/xprtsock.c:xs_setup_local only taking an absolute p=
ath
>>>> and then creating a delayed work item to actually open the unix do=
main
>>>> socket?
>>>>
>>>> The straight correct and straight forward thing to do appears to b=
e:
>>>> - Capture the root from current->fs in xs_setup_local.
>>>> - In xs_local_finish_connect change current->fs.root to the captur=
ed
>>>>    version of root before kernel_connect, and restore current->fs.=
root
>>>>    after kernel_connect.
>>>>
>>>> It might not be a bad idea to implement open on unix domain socket=
s in
>>>> a filesystem as create(AF_LOCAL)+connect() which would allow you t=
o
>>>> replace __sock_create + kernel_connect with a simple file_open_roo=
t.
>>>>
>>>
>>> I like the idea of introducing new family (AF_LOCAL_AT for example)
>>> and new sockaddr for connecting or binding from specified root. The
>>> only thing I'm worrying is passing file descriptor to unix bind or
>>> connect routine. Because this approach doesn't provide easy way to
>>> use such family and sockaddr in kernel (like in NFS example).
>>>
>>>> But I think the simple scheme of:
>>>> struct path old_root;
>>>> old_root =3D current->fs.root;
>>>> kernel_connect(...);
>>>> current->fs.root =3D old_root;
>>>>
>>>> Is more than sufficient and will remove the need for anything
>>>> except a purely local change to get nfs clients to connect from
>>>> containers.
>>>>
>>>
>>> That was my first idea.
>>
>> So is this what you're planning on doing now?
>
> What ever happened to this?
>

Sorry, was busy.
I'll prepare patch today, I hope.

> --b.
>
>>
>>> And probably it would be worth to change all
>>> fs_struct to support sockets with relative path.
>>> What do you think about it?
>>
>> I didn't understand the question.  Are you suggesting that changes t=
o
>> fs_struct would be required to make this work?  I don't see why.
>>
>> --b.


--=20
Best regards,
Stanislav Kinsbursky
