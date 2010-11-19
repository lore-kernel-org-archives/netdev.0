From: Alex Deucher <alexdeucher@gmail.com>
Subject: Re: 2.6.37-rc2-git4: Reported regressions 2.6.35 -> 2.6.36
Date: Fri, 19 Nov 2010 11:39:26 -0500
Message-ID: <AANLkTi=8G7pNA7QTxaXDWKrWrCERPfmKU+nLJWCA=JUH@mail.gmail.com>
References: <tTUH_XeInOH.A.dMF.c3b5MB@chimera>
	<4CE5C919.7090504@teksavvy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	DRI <dri-devel@lists.freedesktop.org>,
	Florian Mickler <florian@mickler.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>
To: Mark Lord <kernel@teksavvy.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4CE5C919.7090504@teksavvy.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 18, 2010 at 7:47 PM, Mark Lord <kernel@teksavvy.com> wrote:
> On 10-11-18 06:50 PM, Rafael J. Wysocki wrote:
>>
>> This message contains a list of some post-2.6.35 regressions introdu=
ced
>> before
>> 2.6.36, for which there are no fixes in the mainline known to the tr=
acking
>> team.
>> If any of them have been fixed already, please let us know.
>>
>> If you know of any other unresolved post-2.6.35 regressions, please =
let us
>> know
>> either and we'll add them to the list. =A0Also, please let us know i=
f any
>> of the entries below are invalid.
>
>> Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D=
21652
>> Subject =A0 =A0 =A0 =A0 : several problems with intel graphics since=
 2.6.36
>> Submitter =A0 =A0 =A0 : Norbert Preining<preining@logic.at>
>> Date =A0 =A0 =A0 =A0 =A0 =A0: 2010-10-27 14:32 (23 days old)
>> Message-ID =A0 =A0 =A0:<20101027143252.GA8676@gamma.logic.tuwien.ac.=
at>
>> References =A0 =A0 =A0: http://marc.info/?l=3Dlinux-kernel&m=3D12881=
8998630241&w=3D2
>
> That one is interesting to me.. I suspect it may be the same cause
> as for https://bugzilla.kernel.org/show_bug.cgi?id=3D21952
>
> I have one of those Samsung (N210) Netbooks here: works fine with 2.6=
=2E34 and
> earlier,
> but fails to come out of suspend on 2.6.35/2.6.36 (haven't tried 2.6.=
37).
>
> So perhaps add 21952 to the list, or link it to the 21652
> (kind of amusing how similar the bug numbers are..).
>
>
> My non-Intel graphics notebook (has ATI X1400 graphics) also has a re=
sume
> regression with 2.6.36. =A0But it does work fine with 2.6.35 (and ear=
lier,
> back many years). =A0As a result, I'm stuck with 2.6.35 for the time =
being,
> and lack the time for a concerted debug effort on 2.6.36+ right now.
>

Can you bisect?  Does this patch help?

diff --git a/drivers/gpu/drm/radeon/atom.c b/drivers/gpu/drm/radeon/ato=
m.c
index 8e421f6..05efb5b 100644
--- a/drivers/gpu/drm/radeon/atom.c
+++ b/drivers/gpu/drm/radeon/atom.c
@@ -112,6 +112,7 @@ static uint32_t atom_iio_execute(struct
atom_context *ctx, int base,
                        base +=3D 3;
                        break;
                case ATOM_IIO_WRITE:
+                       (void)ctx->card->ioreg_read(ctx->card, CU16(bas=
e + 1));
                        ctx->card->ioreg_write(ctx->card, CU16(base + 1=
), temp);
                        base +=3D 3;
                        break;


Alex

> Cheers
> _______________________________________________
> dri-devel mailing list
> dri-devel@lists.freedesktop.org
> http://lists.freedesktop.org/mailman/listinfo/dri-devel
>
