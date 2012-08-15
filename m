From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC PATCH 0/5] net: socket bind to file descriptor introduced
Date: Wed, 15 Aug 2012 14:25:42 -0700
Message-ID: <87k3wzalux.fsf@xmission.com>
References: <20120815161141.7598.16682.stgit@localhost.localdomain>
	<87a9xwc4vr.fsf@xmission.com> <502C0D7C.2040707@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>,
	tglx@linutronix.de, mingo@redhat.com, davem@davemloft.net,
	thierry.reding@avionic-design.de, bfields@redhat.com,
	eric.dumazet@gmail.com, xemul@parallels.com, neilb@suse.de,
	netdev@vger.kernel.org, x86@kernel.org,
	linux-kernel@vger.kernel.org, paul.gortmaker@windriver.com,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	akpm@linux-foundation.org, tim.c.chen@linux.intel.com,
	devel@openvz.org
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <502C0D7C.2040707@zytor.com> (H. Peter Anvin's message of "Wed,
	15 Aug 2012 13:58:36 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"H. Peter Anvin" <hpa@zytor.com> writes:

> On 08/15/2012 12:49 PM, Eric W. Biederman wrote:
>> 
>> There is also the trick of getting a shorter directory name using
>> /proc/self/fd if you are threaded and can't change the directory.
>> 
>> The obvious choices at this point are
>> - Teach bind and connect and af_unix sockets to take longer AF_UNIX
>>   socket path names.
>> 
>> - introduce sockaddr_fd that can be applied to AF_UNIX sockets,
>>   and teach unix_bind and unix_connect how to deal with a second type of sockaddr.
>>   struct sockaddr_fd { short fd_family; short pad; int fd; };
>> 
>> - introduce sockaddr_unix_at that takes a directory file descriptor
>>   as well as a unix path, and teach unix_bind and unix_connect to deal with a
>>   second sockaddr type.
>>   struct sockaddr_unix_at { short family; short pad; int dfd; char path[102]; }
>>   AF_UNIX_AT
>> 
>> I don't know what the implications of for breaking connect up into 3
>> system calls and changing the semantics are and I would really rather
>> not have to think about it.
>> 
>> But it certainly does not look to me like you introduce new systems
>> calls to do what you want.
>> 
>
> How would you distinguish the new sockaddr types from the traditional
> one?  New AF_?

Yeah.  AF_FD or AF_UNIX_AT is what I was thinking.  The way the code
falls out that should be compartively simple to implement.

recvmsg etc would give you sockaddr_un sockets when they come from the
kernel.

Eric
