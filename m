From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [RFC PATCH 5/5] syscall: sys_fbind() introduced
Date: Wed, 15 Aug 2012 20:43:49 +0400
Message-ID: <502BD1C5.6080002@parallels.com>
References: <20120815161141.7598.16682.stgit@localhost.localdomain> <20120815162225.7598.85131.stgit@localhost.localdomain> <502BCEAD.7050905@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "tglx@linutronix.de" <tglx@linutronix.de>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
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
	"devel@openvz.org" <devel@openvz.org>,
	"ebiederm@xmission.com" <ebiederm@xmission.com>
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <502BCEAD.7050905@zytor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

15.08.2012 20:30, H. Peter Anvin =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On 08/15/2012 09:22 AM, Stanislav Kinsbursky wrote:
>> This syscall allows to bind socket to specified file descriptor.
>> Descriptor can be gained by simple open with O_PATH flag.
>> Socket node can be created by sys_mknod().
>>
>> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
>> ---
>>    arch/x86/syscalls/syscall_32.tbl |    1 +
>>    arch/x86/syscalls/syscall_64.tbl |    1 +
>>    include/linux/syscalls.h         |    1 +
>>    kernel/sys_ni.c                  |    3 +++
>>    net/socket.c                     |   25 +++++++++++++++++++++++++
>>    5 files changed, 31 insertions(+), 0 deletions(-)
>>
>> diff --git a/arch/x86/syscalls/syscall_32.tbl b/arch/x86/syscalls/sy=
scall_32.tbl
>> index 7a35a6e..9594b82 100644
>> --- a/arch/x86/syscalls/syscall_32.tbl
>> +++ b/arch/x86/syscalls/syscall_32.tbl
>> @@ -356,3 +356,4 @@
>>    347	i386	process_vm_readv	sys_process_vm_readv		compat_sys_proces=
s_vm_readv
>>    348	i386	process_vm_writev	sys_process_vm_writev		compat_sys_proc=
ess_vm_writev
>>    349	i386	kcmp			sys_kcmp
>> +350	i386	fbind			sys_fbind
>
> i386 uses socketcalls... perhaps it shouldn't (socketcalls are pretty
> much an abomination), but for socketcall-based architectures this rea=
lly
> should be a socketcall.
>

Thanks, Peter. I'll rework this.

> Don't you also need fconnect()?  Or is that simply handled by allowin=
g
> open() without O_PATH?
>

Yes, I need it.
If this approach will be accepted, then I'll send one more patch set fo=
r fconnect.

> 	-hpa
>


--=20
Best regards,
Stanislav Kinsbursky
