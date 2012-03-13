From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v14 01/13] sk_run_filter: add BPF_S_ANC_SECCOMP_LD_W
Date: Tue, 13 Mar 2012 10:40:11 -0500
Message-ID: <CABqD9hZKny+7YOhUtNkcZ0-bfM10MpdoiuYu-9X8Wq99Qk-mQg@mail.gmail.com>
References: <1331587715-26069-1-git-send-email-wad@chromium.org>
	<026393583fec46a9d4401604e596b164.squirrel@webmail.greenhost.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
	markus@chromium.org, coreyb@linux.vnet.ibm.com,
	keescook@chromium.org
To: Indan Zupancic <indan@nul.nu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:58831 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754396Ab2CMPkP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 11:40:15 -0400
Received: by lbbgm6 with SMTP id gm6so298280lbb.19
        for <netdev@vger.kernel.org>; Tue, 13 Mar 2012 08:40:13 -0700 (PDT)
In-Reply-To: <026393583fec46a9d4401604e596b164.squirrel@webmail.greenhost.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 12, 2012 at 10:40 PM, Indan Zupancic <indan@nul.nu> wrote:
> Hello,
>
> On Mon, March 12, 2012 22:28, Will Drewry wrote:
>> Introduces a new BPF ancillary instruction that all LD calls will be
>> mapped through when skb_run_filter() is being used for seccomp BPF. =
=A0The
>> rewriting will be done using a secondary chk_filter function that is=
 run
>> after skb_chk_filter.
>>
>> The code change is guarded by CONFIG_SECCOMP_FILTER which is added,
>> along with the seccomp_bpf_load() function later in this series.
>>
>> This is based on http://lkml.org/lkml/2012/3/2/141
>>
>> v14: First cut using a single additional instruction
>> ... v13: made bpf functions generic.
>>
>>
>> Suggested-by: Indan Zupancic <indan@nul.nu>
>> Signed-off-by: Will Drewry <wad@chromium.org>
>> ---
>> =A0include/linux/filter.h | =A0 =A01 +
>> =A0net/core/filter.c =A0 =A0 =A0| =A0 =A05 +++++
>> =A02 files changed, 6 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/linux/filter.h b/include/linux/filter.h
>> index 8eeb205..aaa2e80 100644
>> --- a/include/linux/filter.h
>> +++ b/include/linux/filter.h
>> @@ -228,6 +228,7 @@ enum {
>> =A0 =A0 =A0 BPF_S_ANC_HATYPE,
>> =A0 =A0 =A0 BPF_S_ANC_RXHASH,
>> =A0 =A0 =A0 BPF_S_ANC_CPU,
>> + =A0 =A0 BPF_S_ANC_SECCOMP_LD_W,
>> =A0};
>>
>> =A0#endif /* __KERNEL__ */
>> diff --git a/net/core/filter.c b/net/core/filter.c
>> index 5dea452..3000931 100644
>> --- a/net/core/filter.c
>> +++ b/net/core/filter.c
>> @@ -350,6 +350,11 @@ load_b:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 A =3D 0;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> +#ifdef CONFIG_SECCOMP_FILTER
>> + =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_ANC_SECCOMP_LD_W:
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 A =3D seccomp_bpf_load(fen=
try->k);
>
> I think you forgot to declare seccomp_bpf_load() anywhere filter.c ca=
n find.
> That is, filter.c probably needs to include seccomp.h, or maybe bette=
r, add
> "extern u32 seccomp_bpf_load(int off);" to filter.h instead.

Doh, it should include seccomp.h.  Right now it gets that on accident
via sched.h.  Since at this point in the patch series, the function
doesn't exist, I'd prefer to just add seccomp.h explicitly.  I'll do
that in the next version unless there is a clear problem.  (In
practice, it is already pulled in.)


> Reviewed-by: Indan Zupancic <indan@nul.nu>

Thanks!
will
