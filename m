From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: MSEC_TO_JIFFIES is messed up...
Date: Wed, 12 May 2004 14:01:58 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0405121400360.11950@bigblue.dev.mdolabs.com>
References: <20040512020700.6f6aa61f.akpm@osdl.org> <20040512181903.GG13421@kroah.com>
 <40A26FFA.4030701@pobox.com> <20040512193349.GA14936@elte.hu>
 <Pine.LNX.4.58.0405121247011.11950@bigblue.dev.mdolabs.com>
 <20040512200305.GA16078@elte.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Davide Libenzi <davidel@xmailserver.org>, Jeff Garzik <jgarzik@pobox.com>,
        Greg KH <greg@kroah.com>, Andrew Morton <akpm@osdl.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ingo Molnar <mingo@elte.hu>
In-Reply-To: <20040512200305.GA16078@elte.hu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 12 May 2004, Ingo Molnar wrote:

> 
> * Davide Libenzi <davidel@xmailserver.org> wrote:
> 
> > > why is it wrong?
> > 
> > For HZ == 1000 it's fine, even if it'd better to explicitly make it HZ
> > dependent and let the compiler to discard them.
> 
> the compiler cannot discard the multiplication and the division from the
> following:
> 
> 	x * 1000 / 1000
> 
> due to overflows.

$ cat foo.c

int foo(int i) {


        return i * 1000 / 1000;
}

$ gcc -S -c foo.c
$ cat foo.s

        .file   "foo.c"
        .text
.globl foo
        .type   foo, @function
foo:
        pushl   %ebp
        movl    %esp, %ebp
        movl    8(%ebp), %eax
        leave
        ret
        .size   foo, .-foo
        .section        .note.GNU-stack,"",@progbits
        .ident  "GCC: (GNU) 3.3.2 20031022 (Red Hat Linux 3.3.2-1)"

$ gcc -v
Reading specs from /usr/lib/gcc-lib/i386-redhat-linux/3.3.2/specs
Configured with: ../configure --prefix=/usr --mandir=/usr/share/man 
--infodir=/usr/share/info --enable-shared --enable-threads=posix 
--disable-checking --with-system-zlib --enable-__cxa_atexit 
--host=i386-redhat-linux
Thread model: posix
gcc version 3.3.2 20031022 (Red Hat Linux 3.3.2-1)



- Davide
