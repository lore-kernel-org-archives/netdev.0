From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] net: ppp: don't call sk_chk_filter twice
Date: Sun, 13 Jul 2014 03:44:59 +0200
Message-ID: <CAADnVQKdTb6B_LsSogr94RS=FwL2Wngc8ACCWavSgaiMqxqdQg@mail.gmail.com>
References: <53BF8DEC.4000307@kristov.de>
	<CAADnVQLQR9fYVGfxfnwpirXt4CwBUzr36tJL+aEoo0err7cppw@mail.gmail.com>
	<20140712231126.103531fxfrk9sola@kristov.noip.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-ppp@vger.kernel.org, paulus@samba.org, isdn@linux-pingi.de
To: Christoph Schulz <develop@kristov.de>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <20140712231126.103531fxfrk9sola@kristov.noip.me>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 12, 2014 at 11:11 PM, Christoph Schulz <develop@kristov.de> wrote:
> Hello!
>
> Alexei Starovoitov schrieb am Sat, 12 Jul 2014 05:59:46 +0200:
>
>
>>> However, sk_chk_filter() is not idempotent as it sometimes replaces
>>> filter
>>> codes. So running it a second time over the same filter does not work and
>>
>>
>> It's a good thing not to call sk_chk_filter() twice, but the commit
>> log is incorrect.
>> sk_chk_filter() doesn't replace filter codes anymore.
>
>
> Fair enough. Then how should I correctly proceed to submit this patch which
> fixes a bug in the 3.15 branch (only)? In 3.15.x filter codes _are_ replaced
> (I just checked the code in 3.15.5). And I originally based my analysis on
> 3.15.1. Your statement makes the patch an optional improvement for 3.16.x,
> but it's a necessary fix for 3.15.x. Do I need to submit this patch two
> times with different commit logs?

I think this patch still makes sense for 'net-next' as cleanup. Just explain it
correctly in the log. It's not needed for 'net'.
As far as stable for 3.15, I'm not yet sure what exactly the problem
you're hitting. The way you describe it, the whole ppp filtering shouldn't
be working in 3.15...

Also it sounds like you've created a patch out of 3.15 tree, but marked it
as 'net-next'. That's not the right. If the tag is 'net-next' it obviously
should be based on net-next tree.
