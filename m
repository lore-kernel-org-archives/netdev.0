From: Diego Viola <diego.viola@gmail.com>
Subject: Dell Inspiron 5558/0VNM2T and suspend/resume problem with r8169
Date: Wed, 1 Mar 2017 12:44:29 -0300
Message-ID: <CA+ToGPHD9qRLer2aVFkNhRmJjKwEf6=sdwyqdW_X463H-Fnh3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

My machine (a Dell Inspiron 5558 laptop) fails to resume from suspend
unless I rmmod r8169 first.

Another workaround is to do this before suspend:

echo 0 > /sys/power/pm_async

I've been reproducing the freeze like this:

$ i3lock && systemctl suspend

I would have to repeat this at least 5 times for the freeze to occur,
but it seems to be easily reproducible.

If I don't invoke i3lock, I cannot get the freeze to happen, but it
seems to happen with other lockers also.

I have tried Alt+SysRq+r and tried to switch to another TTY but the
machine is always unresponsive, which indicates that it's a kernel
panic.

I have had a similar issue to this about a year ago with the jme
driver and this was the fix:

https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/drivers/net/ethernet/jme.c?id=ee50c130c82175eaa0820c96b6d3763928af2241

I haven't tried getting a kernel trace yet, but all seems to indicate
the problem is caused by r8169, at least til now.

Any ideas, please?

Thanks,
Diego
