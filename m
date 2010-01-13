From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH 1/2] net: tcp_header_len_th and tcp_option_len_th
Date: Wed, 13 Jan 2010 03:53:56 -0500
Message-ID: <4B4D8A24.4070108@gmail.com>
References: <4B44FE3C.6060809@gmail.com> <4B450065.4010108@gmail.com> <4B4C519E.2090207@gmail.com> <4B4CB46C.8020502@gmail.com> <4B4CB712.8030806@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755053Ab0AMIyB@vger.kernel.org>
In-Reply-To: <4B4CB712.8030806@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> I type my Changelog text, add my signature, then copy/paste patch from external editor
> (this editor must preserve tabulations of course)
> 
That doesn't work properly on a Mac, copying from BBEdit to Thunderbird.

BBEdit preserves tabs and even understands and preserves Unix LF (and
I've been using it for a Unix editor since it was included with Xinu in
early '90s), but the MacOS copy and paste seems to mangle it.

I'll try again someday with Thunderbird 3, when it's had time to mature.


> About cast games, maybe following way is the cleanest one.
> 
> int tcp_options_len_th(struct tcphdr *th)
> {
> 	return tcp_header_len_th(th) - sizeof(*th);
> }
> 
If you'd have been one of my C students, you'd have failed the exam
question.  That's unsigned int tcp_header_len_th() -- subtracting an
untyped constant could be a negative number (stored in an unsigned).
Then demotion to int (which many compilers truncate to a very large
positive number).

It's one of the reasons that folks used to do all this with macros, so
that the types and truncation were handled well by the compiler.

Of course, this is an inline function, which is more like macros.  I've
not studied how gcc works internally since egcs.

Let's keep (int)(th->doff * 4) - sizeof(*th) -- self documenting, and
should work with a wide variety of compilers.
