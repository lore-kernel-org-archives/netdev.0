From: Jes Sorensen <Jes.Sorensen@redhat.com>
Subject: Re: [PATCH 2/2] rtl8xxxu: Fix for bogus data used to determine macpower
Date: Sun, 30 Oct 2016 19:02:56 -0400
Message-ID: <wrfjzillsan3.fsf@redhat.com>
References: <cover.1477769750.git.john@zgus.com> <20161030102112.GA5789@cube>
        <wrfjpomidp1v.fsf@redhat.com>
        <CAAye0QN0s1S25tDPNWdM6fsVNaO-wLuSy_RoOSoXeuSMeD4oNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: John Heenan <john@zgus.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAye0QN0s1S25tDPNWdM6fsVNaO-wLuSy_RoOSoXeuSMeD4oNA@mail.gmail.com>
        (John Heenan's message of "Sun, 30 Oct 2016 23:56:59 +1000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John Heenan <john@zgus.com> writes:
> Thanks for your reply.
>
> The code was tested on a Cube i9 which has an internal rtl8723bu.
>
> No other devices were tested.
>
> I am happy to accept in an ideal context hard coding macpower is
> undesirable, the comment is undesirable and it is wrong to assume the
> issue is not unique to the rtl8723bu.
>
> Your reply is idealistic. What can I do now?  I should of course have
> factored out other untested devices in my patches. The apparent
> concern you have with process over outcome is a useful lesson.
>
> We are not in an ideal situation. The comment is of course relevant
> and useful to starting a process to fixing a real bug I do not have
> sufficient information to refine any further for and others do. In the
> circumstances nothing really more can be expected.

Well you should start by reporting the issue and either providing a
patch that only affects 8723bu, or work on a generic solution. I
appreciate patches, but I do not appreciate patches that will make
something work for one person and break for everyone else - I spent a
lot of time making sure the driver works across the different devices.

The comment violates all Linux standards - first rule when modifying
code is to respect the style of the code you are dealing with.

Code is 80 characters wide, and comments are /* */ never the ugly C++
crap.

> My patch cover letter, [PATCH 0/2] provides evidence of a mess with
> regard to determining macpower for the rtl8723bu and what is
> subsequently required. This is important.
>
> The kernel driver code is very poorly documented and there is not a
> single source reference to device documentation. For example macpower
> is noting more than a setting that is true or false according to
> whether a read of a particular register return 0xef or not. Such value
> was never obtained so a full init sequence was never performed.

The kernel driver is documented with the information I have - there is
NO device documentation because Realtek refuses to provide any. I have
written the driver based on what I have retried by reading the vendor
drivers. If you can provide better documentation, I certainly would love
to get it.

> It would be helpful if you could provide a link to device references.
> As it is, how am I supposed to revise the patch without relevant
> information?

Look at the USB device table, it shows you which devices are supported.

> My patch code works with the Cube i9, as is, despite a lack of
> adequate information. Before it did not. That is a powerful statement

The driver works with a lot of different devices in itself that is a
powerful statement!

Yes I want to see it work with as many devices as possible, but just
moving things around without balancing it and not explaining why is not
a fix. If we move more of the init sequence to _start() you also have to
move matching pieces to _stop().

Jes
