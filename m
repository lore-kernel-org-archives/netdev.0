From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: MSEC_TO_JIFFIES is messed up...
Date: Wed, 12 May 2004 14:40:17 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0405121439490.11950@bigblue.dev.mdolabs.com>
References: <20040512020700.6f6aa61f.akpm@osdl.org> <20040512181903.GG13421@kroah.com>
 <40A26FFA.4030701@pobox.com> <20040512193349.GA14936@elte.hu>
 <Pine.LNX.4.58.0405121247011.11950@bigblue.dev.mdolabs.com>
 <20040512200305.GA16078@elte.hu> <Pine.LNX.4.58.0405121400360.11950@bigblue.dev.mdolabs.com>
 <20040512211255.GA20800@elte.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>, Greg KH <greg@kroah.com>,
        Andrew Morton <akpm@osdl.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ingo Molnar <mingo@elte.hu>
In-Reply-To: <20040512211255.GA20800@elte.hu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 12 May 2004, Ingo Molnar wrote:

> 
> * Davide Libenzi <davidel@xmailserver.org> wrote:
> 
> > int foo(int i) {
> > 
> > 
> >         return i * 1000 / 1000;
> > }
> 
> try unsigned and you'll see:
> 
>         pushl   %ebp
>         movl    %esp, %ebp
>         movl    8(%ebp), %edx
>         movl    %edx, %eax
>         sall    $2, %eax
>         addl    %edx, %eax
>         leal    0(,%eax,4), %edx
>         addl    %edx, %eax
>         leal    0(,%eax,4), %edx
>         addl    %edx, %eax
>         leal    0(,%eax,8), %edx
>         movl    $274877907, %eax
>         mull    %edx
>         movl    %edx, %eax
>         shrl    $6, %eax
>         leave
>         ret

Yeah, I see.



- Davide
