From: Viresh Kumar <viresh.kumar-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH V4 1/2] ACPI / EC: Fix broken 64bit big-endian users of
	'global_lock'
Date: Sat, 26 Sep 2015 11:40:00 -0700
Message-ID: <CAKohpok0A3JRhVCabscfJGuhJerWmypsQnwdqJcmvBBWdpvPwQ@mail.gmail.com>
References: <e28c4b4deaf766910c366ab87b64325da59c8ad6.1443198783.git.viresh.kumar@linaro.org>
	<4357538.Wlf88yQie6@vostro.rjw.lan>
	<CAKohpok2Z2m7GZt1GzZzofeHEioF=XJEq8YVgtY=VtS9tmpb_Q@mail.gmail.com>
	<2524822.pQu4UKMrlb@vostro.rjw.lan> <20150925214438.GH5951@linux>
	<CAJZ5v0i+xJ4U13vCVsvXc7S8wP0AokbmNXPidBkDwbjXMM8fCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "open list:NETWORKING DRIVERS \(WIRELESS\)"
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"moderated list:SOUND - SOC LAYER / DYNAMIC AUDIO POWER MANAGEM..."
	<alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org>,
	Linaro Kernel Mailman List <linaro-kernel-cunTk1MwBs8s++Sfvej+rw@public.gmane.org>,
	"open list:TARGET SUBSYSTEM" <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"open list:ULTRA-WIDEBAND \(UWB\) SUBSYSTEM:" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-LthD3rsA81gm4RdzfppkhA@public.gmane.org>,
	QCA ath9k Development <ath9k-devel-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"open list:AMD IOMMU \(AMD-VI\)" <iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	"open list:BLUETOOTH DRIVERS" <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netd
To: "Rafael J. Wysocki" <rafael-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAJZ5v0i+xJ4U13vCVsvXc7S8wP0AokbmNXPidBkDwbjXMM8fCw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 25 September 2015 at 15:19, Rafael J. Wysocki <rafael-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> So if you allow something like debugfs to update your structure, how
> do you make sure there is the proper locking?

Not really sure at all.. Isn't there some debugfs locking that will
jump in, to avoid updation of fields to the same device?

> Is that not a problem in all of the places modified by the [2/2]?

Right, but its not new AFAICT.

We already have u32 fields in those structs and on 64 bit machines
we have the same read-update-write problems for two consecutive
u32's. Right?

> How can the future users of the API know what to do to avoid potential
> problems with it?

No idea really :)

>> Anyway, that problem isn't here for sure as its between two
>> unsigned-longs. So, should I just move it to bool and resend ?
>
> I guess it might be more convenient to fold this into the other patch,
> because we seem to be splitting hairs here.

I can and that's what I did. But then Arnd asked me to separate it
out. I can fold it back if that's what you want.

--
viresh
