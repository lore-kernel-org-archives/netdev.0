From: Milton Miller <miltonm@bga.com>
Subject: Re: How to get backtrace? modprobe -r iwlagn; modprobe iwlagn kills kernel
Date: Wed, 18 May 2011 10:55:01 -0500
Message-ID: <1305734101_6569@mail4.comsite.net>
References: <201105181637.46164.stevie.trujillo@gmail.com>
Cc: <linux-kernel@vger.kernel.org>, <linux-wireless@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Stevie Trujillo <stevie.trujillo@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201105181637.46164.stevie.trujillo@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed May 18 2011 about 10:37:54 EST, Stevie Trujillo wrote:
> I'm having some problem getting a backtrace. When I do "modprobe -r
> iwlagn; modprobe iwlagn" (2.6.38.6 with Intel-1030N) the kernel crashes
> (sometimes I need to try 2 or 3 times, and sometimes the modprobe -r
> is the one that crashes).
> 
> This spams my monitor with several oops/panics before it finally
> dies. I can only see bottom of the last one, which probably isn't
> very meaningful.  I tried loading netconsole, but I only get one or
> two lines before it stops sending/printing.
> 
> I then tried kexec+crashkernel, but I only managed to get a backtrace
> for the last panic (which I think is just a result of memory corruption
> or something).  Finally I tried compiling ramoops into my kernel,
> but it didn't want to load because of "No such device".

For the kexec+crashkernel, try to retrieve the kernel log buffer:

There are some macros available, but basically log_buf is a pointer
to a buffer of length log_buf_len initialized to __log_buf (but can
be expanded via the command line or sysctl, in). log_end is the
end of the buffer.  If you haven't wrapped then just print log_end
characters.

Also consider setting /proc/sys/kernel/panic_on_oops to 1 to
concentrate on the first one.  It won't help getting the oops to your
syslog but maybe it will keep it on the screen.

Hope this helps,
milton
