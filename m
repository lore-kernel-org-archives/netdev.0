From: Ingo Molnar <mingo@elte.hu>
Subject: Re: MSEC_TO_JIFFIES is messed up...
Date: Wed, 12 May 2004 23:12:55 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040512211255.GA20800@elte.hu>
References: <20040512020700.6f6aa61f.akpm@osdl.org> <20040512181903.GG13421@kroah.com> <40A26FFA.4030701@pobox.com> <20040512193349.GA14936@elte.hu> <Pine.LNX.4.58.0405121247011.11950@bigblue.dev.mdolabs.com> <20040512200305.GA16078@elte.hu> <Pine.LNX.4.58.0405121400360.11950@bigblue.dev.mdolabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Greg KH <greg@kroah.com>,
        Andrew Morton <akpm@osdl.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Davide Libenzi <davidel@xmailserver.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0405121400360.11950@bigblue.dev.mdolabs.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* Davide Libenzi <davidel@xmailserver.org> wrote:

> int foo(int i) {
> 
> 
>         return i * 1000 / 1000;
> }

try unsigned and you'll see:

        pushl   %ebp
        movl    %esp, %ebp
        movl    8(%ebp), %edx
        movl    %edx, %eax
        sall    $2, %eax
        addl    %edx, %eax
        leal    0(,%eax,4), %edx
        addl    %edx, %eax
        leal    0(,%eax,4), %edx
        addl    %edx, %eax
        leal    0(,%eax,8), %edx
        movl    $274877907, %eax
        mull    %edx
        movl    %edx, %eax
        shrl    $6, %eax
        leave
        ret

    Ingo
