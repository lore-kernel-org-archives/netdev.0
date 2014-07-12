From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] net: ppp: don't call sk_chk_filter twice
Date: Sat, 12 Jul 2014 12:23:06 +0200
Message-ID: <53C10C8A.70706@redhat.com>
References: <53BF8DEC.4000307@kristov.de> <CAADnVQLQR9fYVGfxfnwpirXt4CwBUzr36tJL+aEoo0err7cppw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Schulz <develop@kristov.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-ppp@vger.kernel.org, paulus@samba.org, isdn@linux-pingi.de
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31719 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751000AbaGLKXe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jul 2014 06:23:34 -0400
In-Reply-To: <CAADnVQLQR9fYVGfxfnwpirXt4CwBUzr36tJL+aEoo0err7cppw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/12/2014 05:59 AM, Alexei Starovoitov wrote:
> On Fri, Jul 11, 2014 at 9:10 AM, Christoph Schulz <develop@kristov.de> wrote:
>> From: Christoph Schulz <develop@kristov.de>
>>
>> Commit 568f194e8bd16c353ad50f9ab95d98b20578a39d ("net: ppp: use
>> sk_unattached_filter api") causes sk_chk_filter() to be called twice when
>> setting a pass or active filter. The first call is from within get_filter().
>> The second one is through the call chain
>>
>>    ppp_ioctl() --> sk_unattached_filter_create()
>>                --> __sk_prepare_filter()
>>                --> sk_chk_filter()
>>
>> However, sk_chk_filter() is not idempotent as it sometimes replaces filter
>> codes. So running it a second time over the same filter does not work and
>
> It's a good thing not to call sk_chk_filter() twice, but the commit
> log is incorrect.
> sk_chk_filter() doesn't replace filter codes anymore.

Exactly.
