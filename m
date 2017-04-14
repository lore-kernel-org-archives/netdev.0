From: Alexander Duyck <alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: How to debug DMAR errors?
Date: Fri, 14 Apr 2017 08:45:15 -0700
Message-ID: <CAKgT0UcEKTsc6-tSHXMHFybnE4NQASKWHziq2SV+spOCLJGH-g@mail.gmail.com>
References: <a21d8845-ae8d-fae0-b1b4-7bf6751b04b5@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <a21d8845-ae8d-fae0-b1b4-7bf6751b04b5-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 13, 2017 at 11:12 AM, Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org> wrote:
> Hello,
>
> I have been seeing a regular occurrence of DMAR errors, looking something
> like this when testing my ath10k driver/firmware under some specific loads
> (maximum receive of 512 byte frames in AP mode):
>
> DMAR: DRHD: handling fault status reg 3
> DMAR: [DMA Read] Request device [05:00.0] fault addr fd99f000 [fault reason
> 06] PTE Read access is not set
> ath10k_pci 0000:05:00.0: firmware crashed! (uuid
> 594b1393-ae35-42b5-9dec-74ff0c6791ff)
>
> So, I am wondering if there is any way I can get more information about what
> this fd99f000 address
> is?
>
> Once this problem hits, the entire OS locks hard (not even sysrq-boot will
> do anything),
> so I guess I would need the DMAR logic to print out more info on that
> address somehow.
>
> Thanks,
> Ben

There isn't much more info to give you. The problem is that the device
at 5:00.0 attempted to read at fd99f000 even though it didn't have
permissions. In response this should trigger a PCI Master Abort
message to that function. It looks like the firmware for the device
doesn't handle that and so that is likely why things got hung.

Really you would need to interrogate the ath10k_pci to see if there
is/was a mapping somewhere for that address and what it was supposed
to be used for.

- Alex
