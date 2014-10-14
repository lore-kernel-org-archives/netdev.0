From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH linux v3 1/1] fs/proc: use a rb tree for the directory entries
Date: Tue, 14 Oct 2014 12:56:11 -0700
Message-ID: <87y4sis9wk.fsf@x220.int.ebiederm.org>
References: <20141006.181448.1696747135961247651.davem@davemloft.net>
	<1412672559-5256-1-git-send-email-nicolas.dichtel@6wind.com>
	<1412672559-5256-2-git-send-email-nicolas.dichtel@6wind.com>
	<543BB42B.30505@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, akpm@linux-foundation.org,
	adobriyan@gmail.com, rui.xiang@huawei.com, viro@zeniv.linux.org.uk,
	oleg@redhat.com, gorcunov@openvz.org,
	kirill.shutemov@linux.intel.com, grant.likely@secretlab.ca,
	tytso@mit.edu, Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: nicolas.dichtel@6wind.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <543BB42B.30505@6wind.com> (Nicolas Dichtel's message of "Mon, 13
	Oct 2014 13:14:51 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:

> Le 07/10/2014 11:02, Nicolas Dichtel a =C3=A9crit :
>> The current implementation for the directories in /proc is using a s=
ingle
>> linked list. This is slow when handling directories with large numbe=
rs of
>> entries (eg netdevice-related entries when lots of tunnels are opene=
d).
>>
>> This patch replaces this linked list by a red-black tree.
>>
>> Here are some numbers:
>>
>> dummy30000.batch contains 30 000 times 'link add type dummy'.
>>
>> Before the patch:
>> $ time ip -b dummy30000.batch
>> real	2m31.950s
>> user	0m0.440s
>> sys	2m21.440s
>> $ time rmmod dummy
>> real	1m35.764s
>> user	0m0.000s
>> sys	1m24.088s
>>
>> After the patch:
>> $ time ip -b dummy30000.batch
>> real	2m0.874s
>> user	0m0.448s
>> sys	1m49.720s
>> $ time rmmod dummy
>> real	1m13.988s
>> user	0m0.000s
>> sys	1m1.008s
>>
>> The idea of improving this part was suggested by
>> Thierry Herbelot <thierry.herbelot@6wind.com>.
>>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> Acked-by: David S. Miller <davem@davemloft.net>
Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>
>> ---
>
> I'm not sure who is in charge of taking this patch. Should I resend i=
t to
> someone else or is it already included in a tree?

There are a couple of things going on here.

This patch came out at the beginning of the merge window which is a tim=
e
when everything that was ready and well tested ahead of time gets
merged.

Your numbers don't look too bad, so I expect this code is ready to go
(although I am a smidge disappointed in the small size of the
performance improvement), my quick read through earlier did not show
anything scary.   Do you have any idea why going from O(N^2) algorithm
to a O(NlogN) algorithm showed such a small performance improvement wit=
h
30,000 entries?

Normally proc is looked at by a group of folks me, Alexey Dobriyan, and
Al Viro all sort of tag team taking care of the proc infrastructure wit=
h
(except for Al) Andrew Morton typically taking the patches and merging
them.

I am currently in the middle of a move so I don't have the time to carr=
y
this change or do much of anything until I am settled again.

What I would recommend is verifying your patch works against v3.18-rc1
at the begginning of next week and sending the code to Andrew Morton.

Eric
