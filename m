From: "Rafael J. Wysocki" <rafael@kernel.org>
Subject: Re: [PATCH V4 1/2] ACPI / EC: Fix broken 64bit big-endian users of 'global_lock'
Date: Sat, 26 Sep 2015 00:19:56 +0200
Message-ID: <CAJZ5v0i+xJ4U13vCVsvXc7S8wP0AokbmNXPidBkDwbjXMM8fCw@mail.gmail.com>
References: <e28c4b4deaf766910c366ab87b64325da59c8ad6.1443198783.git.viresh.kumar@linaro.org>
	<4357538.Wlf88yQie6@vostro.rjw.lan>
	<CAKohpok2Z2m7GZt1GzZzofeHEioF=XJEq8YVgtY=VtS9tmpb_Q@mail.gmail.com>
	<2524822.pQu4UKMrlb@vostro.rjw.lan>
	<20150925214438.GH5951@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Johannes Berg <johannes@sipsolutions.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>,
	QCA ath9k Development <ath9k-devel@qca.qualcomm.com>, Intel Linux Wireless <ilw@linux.intel.com>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	"open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>,
	"open list:AMD IOMMU (AMD-VI)" <iommu@lists.linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"open list:NETWORKING DRIVERS (WIRELESS)" <linux-wireless@vger.kernel.org>,
	"open list:TARGET SUBSYSTEM" <linux-scsi@vger.kernel.org>,
	"open list:ULTRA-WIDEBAND
To: Viresh Kumar <viresh.kumar@linaro.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20150925214438.GH5951@linux>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 25, 2015 at 11:44 PM, Viresh Kumar <viresh.kumar@linaro.org> wrote:
> On 25-09-15, 22:58, Rafael J. Wysocki wrote:
>> Say you have three adjacent fields in a structure, x, y, z, each one byte long.
>> Initially, all of them are equal to 0.
>>
>> CPU A writes 1 to x and CPU B writes 2 to y at the same time.
>>
>> What's the result?
>
> But then two CPUs can update the same variable as well, and we must
> have proper locking in place to fix that.

Right.

So if you allow something like debugfs to update your structure, how
do you make sure there is the proper locking?

Is that not a problem in all of the places modified by the [2/2]?

How can the future users of the API know what to do to avoid potential
problems with it?

>
> Anyway, that problem isn't here for sure as its between two
> unsigned-longs. So, should I just move it to bool and resend ?

I guess it might be more convenient to fold this into the other patch,
because we seem to be splitting hairs here.

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
