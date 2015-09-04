From: Michael Tirado <mtirado418@gmail.com>
Subject: eBPF / seccomp globals?
Date: Fri, 4 Sep 2015 01:01:20 +0000
Message-ID: <CAMkWEXPxrth6Bt1X1OhAQYMWPM5XSy2oJEtCkv1grLFNYo5Edg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hiyall,

I have created a seccomp white list filter for a program that launches
other less trustworthy programs.  It's working great so far, but I
have run into a little roadblock.  the launcher program needs to call
execve as it's final step, but that may not be present in the white
list.  I am wondering if there is any way to use some sort of global
variable that will be preserved between syscall filter calls so that I
can allow only one execve, if not present in white list by
incrementing a counter variable.

I see that in Documentation/networking/filter.txt one of the registers
is documented as being a pointer to struct sk_buff, in the seccomp
context this is a pointer to struct seccomp_data  instead, right?  and
the line about callee saved registers R6-R9  probably refers to them
being saved across calls within that filter, and not calls between
filters?

My apologies if this is not the appropriate place to ask for help, but
it is difficult to find useful information on how eBPF works, and is a
bit confusing trying to figure out the differences between seccomp and
net filters, and the old bpf code kicking around short of spending
countless hours reading through all of it.  If anybody has a some
links to share I would be very grateful.  the only way I can think to
make this work otherwise is to mount everything as MS_NOEXEC in the
new namespace, but that just feels wrong.
