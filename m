From: Kalle Valo <kvalo@adurom.com>
Subject: Re: [PATCH v3 0/2] Fix uevent race in register_netdevice()
Date: Fri, 20 May 2011 15:08:58 +0300
Message-ID: <87oc2xd15x.fsf@purkki.adurom.net>
References: <20110516143913.13838.85357.stgit@localhost6.localdomain6>
	<20110516.141158.1777924960833804150.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110516.141158.1777924960833804150.davem@davemloft.net> (David Miller's message of "Mon\, 16 May 2011 14\:11\:58 -0400 \(EDT\)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: Kalle Valo <kvalo@adurom.com>
> Date: Mon, 16 May 2011 17:46:30 +0300
>
>> I'm trying to fix a race in register_netdevice(). The problem is that
>> there's a uevent to userspace before the netdevice is ready for use. The
>> problem is described here:
>> 
>> https://bugzilla.kernel.org/show_bug.cgi?id=15606
>> 
>> I have sent few different ways to fix this, but none of them have been
>> really usable. Now I came up with a way which changes the driver core
>> to make it possible send the uevent in a separate call. This is a clean
>> and safe way to fix the race. Downside is that two new functions are
>> added to the driver core interface.
>> 
>> Please comment.
>
> This doesn't work.
>
> The sysfs file will still be there before the uevent, so any
> process can go in there, and see the inconsistent state.

I considered that user space would not notice the device until the
uevent is emitted so that wouldn't matter that much.

But it's back to the drawing board again. I'm running out of options
how to do this in a not so intrusive way. Do you have any tips how to
fix the race for good?

-- 
Kalle Valo
