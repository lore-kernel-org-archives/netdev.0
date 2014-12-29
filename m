From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: am335x: cpsw: interrupt failure
Date: Mon, 29 Dec 2014 08:46:48 -0500
Message-ID: <54A15B48.9010407@hurleysoftware.com>
References: <CAGm1_ksPkFXV_S6541cK1TQb_eRTHbspZy4zWxY5GMrrjGD2tA@mail.gmail.com> <20141204165609.GJ18045@saruman> <CAGm1_ksNuO75QfgaDUpOe525xDkPhby-z8T=MX3DHdB-LVcR8g@mail.gmail.com> <20141210171724.GI4602@saruman> <CAGm1_ksziwSjQnV1rDYsAv2QQCvhnZPOimowmsW5Cib7C01aqA@mail.gmail.com> <20141210210234.GN4602@saruman> <CAGm1_ktYg4iDgK7jyi5etSVup61LdookkV+SaQZOpLb6M=y7hA@mail.gmail.com> <CAGm1_kuaqXrU4zhNUZeY85+OeXHApSUDjJdsXcyBdvHTNhLCmQ@mail.gmail.com> <20141212173210.GI7549@saruman> <CAGm1_kuYrGsfjRO6TVr554yS8dcD4_Z9-j9KL0xpD=X+31OkXQ@mail.gmail.com> <CAGm1_kudtF9O4QChrKX1q=c9KwHEFZet=z7j=-_iCRE914X83Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
To: Yegor Yefremov <yegorslists@googlemail.com>,
	Felipe Balbi <balbi@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <CAGm1_kudtF9O4QChrKX1q=c9KwHEFZet=z7j=-_iCRE914X83Q@mail.gmail.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/29/2014 04:33 AM, Yegor Yefremov wrote:
> On Fri, Dec 12, 2014 at 8:19 PM, Yegor Yefremov
> <yegorslists@googlemail.com> wrote:
>> On Fri, Dec 12, 2014 at 6:32 PM, Felipe Balbi <balbi@ti.com> wrote:
>>> Hi,
>>>
>>> On Fri, Dec 12, 2014 at 01:00:51PM +0100, Yegor Yefremov wrote:
>>>> U-Boot version: 2014.07
>>>> Kernel config is omap2plus with enabled USB
>>>>
>>>> # cat /proc/version
>>>> Linux version 3.18.0 (user@user-VirtualBox) (gcc version 4.8.3
>>>> 20140320 (prerelease) (Sourcery CodeBench Lite 2014.05-29) ) #6 SMP
>>>> Mon Dec 8 22:47:43 CET 2014
>>>
>>> Wasn't GCC 4.8.x total crap for building ARM kernels ? IIRC it was even
>>> blacklisted. Can you try with 4.9.x just to make sure ?
>>
>> Will do.
> 
> Adding linux-omap. Beginning of this discussion:
> http://comments.gmane.org/gmane.linux.network/341427
> 
> Quick summary: starting with kernel 3.18 or commit
> 55601c9f24670ba926ebdd4d712ac3b177232330 am335x (at least BBB and some
> custom boards) stalls at high network load. Reproducible via nuttcp
> within some minutes
> 
> nuttcp -S (on BBB)
> nuttcp -t -N 4 -T30m 192.168.1.235 (on host)
> 
> As Felipe Balbi suggested, I tried both 4.8.3 and 4.9.2 toolchains,
> but both show the same behavior.
> 
> Linux version 3.18.0 (user@user-VirtualBox) (gcc version 4.8.3
> 20140320 (prerelease) (Sourcery CodeBench Lite 2014.05-29) ) #6 SMP
> Mon Dec 8 22:47:43 CET 2014
> Linux version 3.18.1 (user@user-VirtualBox) (gcc version 4.9.2
> (Buildroot 2015.02-git-00582-g10b9761) ) #1 SMP Mon Dec 29 09:22:29
> CET 2014
> 
> Let me know, if you can reproduce this issue.

I have seen the irq 0 error messages on the black since 3.18+, but didn't
bisect it yet. For me, these errors occurred with a slightly misconfigured
emacs24-nox, which drove the cpu load way up - over 50% - with just
cursor movement (it still gets above 20% which seems unacceptably high).

I'm not sure if all the crashes were over ssh; I hadn't considered
the cpsw relevant until reading this. I'll retest over the serial console.

I have seen abrupt resets without messages on earlier kernels so perhaps
the commit is not the root cause.

Regards,
Peter Hurley

