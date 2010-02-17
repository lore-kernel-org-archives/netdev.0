From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [net-next PATCH v4 0/3] net: reserve ports for applications using fixed port
Date: Wed, 17 Feb 2010 08:10:21 -0800
Message-ID: <m1ljer3ksy.fsf@fess.ebiederm.org>
References: <1266271241-6293-1-git-send-email-opurdila@ixiacom.com>
	<201002162151.04861.opurdila@ixiacom.com>
	<m1mxz93pw2.fsf@fess.ebiederm.org>
	<201002162322.13101.opurdila@ixiacom.com>
	<4B7C11D4.1080309@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B7C11D4.1080309@redhat.com> (Cong Wang's message of "Wed\, 17 Feb 2010 23\:57\:08 +0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cong Wang <amwang@redhat.com> writes:

> Octavian Purdila wrote:
>> On Tuesday 16 February 2010 22:08:13 you wrote:
>>>> Something like bellow?
>>>>
>>>> # set bits 8080 and 1666
>>>> $echo 8080 1666-1666 > /proc
>>>>
>>>> #reset bit 1666
>>>> $echo 8080 > /proc
>>>>
>>>> #reset whole bitmap
>>>> $echo > /proc
>>> Yes. So something like that.
>>>
>>> I think I would use commas instead of spaces as that is more traditional.
>
>
> Why this is better than the current version?
>
> For the single port case, currently we use:
>
> echo +8080 > /xxxx #set
> echo -8080 > /xxxx #clear
>
> Now we will use:
>
> echo 8080 > /xxxx #set
> echo 8080 > /xxxx #clear

No.

> I don't think the latter is better...
>
> For the multi-port case, yes, we should accept 'echo 8080,10000 >/xxxx'.

What I was envisioning was:

echo 8080 > /xxx # set the bitmap to 8080
echo 8080,10000 > /xxx # add 10000 to the bitmap
echo 8080 > /xxxx # remove 10000 from the bitmap.

That is when you set it you enter the entire set every time, treating
the entire set as a single value.

Eric
