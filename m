From: Sri Ram Vemulpali <sri.ram.gmu06@gmail.com>
Subject: Re: orphan process is causing deadlock in __kernel_vsyscall ()
Date: Thu, 26 Jul 2012 08:54:49 -0400
Message-ID: <CALyraeM9WXraZeV-6-YC7NqGfY8yokkepjeznwJoZ+EbHhdxnQ@mail.gmail.com>
References: <CALyraeOQZ+FPTqaOk6XjHsZwwCfNuo2XLo6bhw44maSEkDf7tA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-kernel-mail <linux-kernel@vger.kernel.org>,
	linux-newbie@vger.kernel.org,
	linux-netdev <netdev@vger.kernel.org>,
	kernelnewbies <Kernelnewbies@kernelnewbies.org>,
	Kernel-newbies <kernelnewbies@nl.linux.org>
Return-path: <linux-newbie-owner@vger.kernel.org>
In-Reply-To: <CALyraeOQZ+FPTqaOk6XjHsZwwCfNuo2XLo6bhw44maSEkDf7tA@mail.gmail.com>
Sender: linux-newbie-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Hello All,
>
> I am debugging a problem which I do not know how to solve. I know what
> is happening, but cannot find solution to it. If anyone has any
> suggestions or solution that would be really grateful and I appreciate
> it.
>
> Here is the description.
>
> I have a thread which spawns a child process using fork() and in child
> context it execv to shell and parent thread waits on waitpid(). This
> child process is nothing but a shell /bin/sh, so that from program I
> can create shell and run some commands.
> In this shell instance, I run tshark for capturing network traffic. I
> have really high traffic going, so system is really busy. All is good
> so far, but when I send SIGKILL to child process (shell) from another
> thread from same application,
> child process (shell) gets terminated and tshark is assigned to
> init(1) process as orphan. The parent thread which spawned the child
> process unblocks from waitpid() after cleaning child instance and
> continues it execution.
>
> Here is the problem:
> Once the parent thread resumes from waitpid(), it hits fprintf to
> print message "exiting from shell" to console. In here the main thread
> gets blocked in __kernel_vsyscall () entered from fprintf. Following
> is my stack trace from gdb.
> But after some more debugging and found that, if I kill from another
> shell "tshark" process which is assigned to init(1) as child, the
> parent thread unblocks from __kernel_vsyscall ().
>
> Can anyone tell what is going on, is this related to futex spinning
> problem where lock is been held by tshark. How would I approach this
> problem?
> Or is there a way to kill all child process of a process without
> making them orphan. Because when a child process is running at the
> time parent is exiting, that child process is assigned to init(1) as
> orphan process.
> Can this behavior be modified. Please let me know any suggestions and
> thoughts. Thanks in advance.
>
> --
> Regards,
> Sri.
>
> (gdb) backtrace
> #0  0xffffe424 in __kernel_vsyscall ()
> #1  0xb7e6396b in write () from /lib/libc.so.6
> #2  0xb7e0c2ef in _IO_new_file_write () from /lib/libc.so.6
> #3  0xb7e0bf93 in new_do_write () from /lib/libc.so.6
> #4  0xb7e0c296 in _IO_new_do_write () from /lib/libc.so.6
> #5  0xb7e0ce20 in _IO_new_file_overflow () from /lib/libc.so.6
> #6  0xb7e0c0cd in _IO_new_file_xsputn () from /lib/libc.so.6
> #7  0xb7de3634 in vfprintf () from /lib/libc.so.6
> #8  0x09ad62a2 in acme_fprintf (stream=0xb7ee2560,
>     format=0x9f17694 "shell exited. returning to acli\n")
>     at /home/svemulpali/cc/svemulpali_SCOTTY_main/linux/private/common/src/coutOverride.cpp:42
> #9  0x094a9345 in vxShellCmdStartWait (syscmd=0x0)
>     at /home/svemulpali/cc/svemulpali_SCOTTY_main/linux/private/lib/stub/vxShellLib.cpp:210



-- 
Regards,
Sri.
--
To unsubscribe from this list: send the line "unsubscribe linux-newbie" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at http://www.linux-learn.org/faqs
