From: Jens Axboe <jaxboe-5c4llco8/ftWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH RESEND block#for-2.6.36] block_dev: always serialize
 exclusive open attempts
Date: Thu, 5 Aug 2010 11:20:51 +0200
Message-ID: <4C5A8273.2010803@fusionio.com>
References: <2dWFdr9kTFM.A.P0D.spXVMB@chimera> <AANLkTimcH7+Bq1UEbaSU7SQpzArPgmSLegiqE13V8=CF@mail.gmail.com> <4C56F30D.3020304@kernel.org> <4C598E6B.7050405@gmail.com> <4C5A7E33.3060101@fusionio.com> <20100805091704.GA1772@arch.tripp.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Markus Trippelsdorf <markus-xp2qqqlHh3xzoYq+O6RWwA@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100805091704.GA1772-joY5NpejW+Hx3b7vapvTcQ@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2010-08-05 11:17, Markus Trippelsdorf wrote:
> On Thu, Aug 05, 2010 at 11:02:43AM +0200, Jens Axboe wrote:
>> On 2010-08-04 17:59, Tejun Heo wrote:
>>> bd_prepare_to_claim() incorrectly allowed multiple attempts for
>>> exclusive open to progress in parallel if the attempting holders are
>>> identical.  This triggered BUG_ON() as reported in the following bug.
>>>
>>>   https://bugzilla.kernel.org/show_bug.cgi?id=16393
>>>
>>> __bd_abort_claiming() is used to finish claiming blocks and doesn't
>>> work if multiple openers are inside a claiming block.  Allowing
>>> multiple parallel open attempts to continue doesn't gain anything as
>>> those are serialized down in the call chain anyway.  Fix it by always
>>> allowing only single open attempt in a claiming block.
>>>
>>> This problem can easily be reproduced by adding a delay after
>>> bd_prepare_to_claim() and attempting to mount two partitions of a
>>> disk.
>>>
>>> stable: only applicable to v2.6.35
>>>
>>> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
>>> Reported-by: Markus Trippelsdorf <markus-xp2qqqlHh3xzoYq+O6RWwA@public.gmane.org>
>>> Cc: stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
>>
>> Thanks Tejun, applied.
> 
> It's already in mainline:
> e75aa85892b2ee78c79edac720868cbef16e62eb

Irk, had not noticed yet, my for-2.6.36 branch isn't fully merged
up yet. Thanks for the heads-up.

-- 
Jens Axboe


Confidentiality Notice: This e-mail message, its contents and any attachments to it are confidential to the intended recipient, and may contain information that is privileged and/or exempt from disclosure under applicable law. If you are not the intended recipient, please immediately notify the sender and destroy the original e-mail message and any attachments (and any copies that may have been made) from your system or otherwise. Any unauthorized use, copying, disclosure or distribution of this information is strictly prohibited.
