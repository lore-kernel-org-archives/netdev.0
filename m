From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v3 2/2] decrement static keys on real destroy time
Date: Thu, 26 Apr 2012 15:22:33 -0700
Message-ID: <CAOS58YOKUq7GTTZRcw19dth+HgThoNTEcqBKeNO0ftB4rFJ97A@mail.gmail.com>
References: <1335475463-25167-1-git-send-email-glommer@parallels.com>
	<1335475463-25167-3-git-send-email-glommer@parallels.com>
	<20120426213916.GD27486@google.com>
	<4F99C50D.6070503@parallels.com>
	<20120426221324.GE27486@google.com>
	<4F99C980.3030801@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F99C980.3030801-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

On Thu, Apr 26, 2012 at 3:17 PM, Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> wrote:
>
>> No, what I mean is that why can't you do about the same mutexed
>> activated inside static_key API function instead of requiring every
>> user to worry about the function returning asynchronously.
>> ie. synchronize inside static_key API instead of in the callers.
>>
>
> Like this?

Yeah, something like that.  If keeping the inc operation a single
atomic op is important for performance or whatever reasons, you can
play some trick with large negative bias value while activation is
going on and use atomic_add_return() to determine both whether it's
the first incrementer and someone else is in the process of
activating.

Thanks.

-- 
tejun
