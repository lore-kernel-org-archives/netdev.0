From: Patrick McLean <patrickm@gaikai.com>
Subject: Re: [Intel-wired-lan] [PATCH] (resend) ixgbe: always initialize setup_fc
Date: Fri, 8 Jul 2016 09:44:49 -0700
Message-ID: <CAE2NFgVpZoBrNTFV8J3uybuowDj=84nTwgRkta9B0OqGRg-ZDQ@mail.gmail.com>
References: <CAE2NFgXe4uPT1WDVzSq_rr54XA7xDNuedoBgHdtd2_WekNQZ+A@mail.gmail.com>
 <038AE347-E85C-4738-BC91-C8C16AE88620@intel.com> <87618083B2453E4A8714035B62D679925066EACF@FMSMSX105.amr.corp.intel.com>
 <CAD=hENdLDK6Odi=oV2CNsoKR2_z4tM3oSSgtaA0yiyofErwrog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a1143e1987c777c05372285c7
Cc: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Rustad, Mark D" <mark.d.rustad@intel.com>,
	netdev <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>
To: zhuyj <zyjzyj2000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f53.google.com ([209.85.214.53]:38540 "EHLO
	mail-it0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755711AbcGHQow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 12:44:52 -0400
Received: by mail-it0-f53.google.com with SMTP id h190so13700968ith.1
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 09:44:52 -0700 (PDT)
In-Reply-To: <CAD=hENdLDK6Odi=oV2CNsoKR2_z4tM3oSSgtaA0yiyofErwrog@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a1143e1987c777c05372285c7
Content-Type: text/plain; charset=UTF-8

How about just initializing it when the rest of the struct is
initialized? This is what is done for every other model.

On Fri, Jul 8, 2016 at 2:47 AM, zhuyj <zyjzyj2000@gmail.com> wrote:
> Sure. setup_fc should not be null. Emil, your patch can fix it well.
>
> On Fri, Jul 8, 2016 at 8:18 AM, Tantilov, Emil S <emil.s.tantilov@intel.com>
> wrote:
>>
>> >-----Original Message-----
>> >From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org]
>> > On
>> >Behalf Of Rustad, Mark D
>> >Sent: Wednesday, July 06, 2016 4:01 PM
>> >To: Patrick McLean <patrickm@gaikai.com>
>> >Cc: netdev <netdev@vger.kernel.org>; intel-wired-lan <intel-wired-
>> >lan@lists.osuosl.org>
>> >Subject: Re: [Intel-wired-lan] [PATCH] (resend) ixgbe: always initialize
>> >setup_fc
>> >
>> >Patrick McLean <patrickm@gaikai.com> wrote:
>> >
>> >> Gmail mangled my first message, sorry about that. Second attempt.
>> >>
>> >> In ixgbe_init_mac_link_ops_X550em, the code has a special case for
>> >> backplane media type, but does not fall through to the default case,
>> >> so the setup_fc never gets initialized. This causes a panic when it
>> >> later tries to set up the card, and the kernel dereferences the null
>> >> pointer.
>> >>
>> >> This patch lets the the function fall through, which initialized
>> >> setup_fc properly.
>> >
>> >I don't think that this is the right fix. My memory is that fc autoneg is
>>
>> setup_fc() does not configure FC autoneg and it should always be set.
>>
>> I posted an alternative patch that simply sets setup_fc at the beginning
>> of
>> the function. The fall-through in the switch statement is not a good
>> solution
>> because it won't work in case we need to add another case.
>>
>> http://patchwork.ozlabs.org/patch/646228/
>>
>> Thanks,
>> Emil
>>
>

--001a1143e1987c777c05372285c7
Content-Type: text/x-patch; charset=US-ASCII;
	name="ixgbe-x550-always-initialize-setup_fc.patch"
Content-Disposition: attachment;
	filename="ixgbe-x550-always-initialize-setup_fc.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iqdz1tmt0

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L2V0aGVybmV0L2ludGVsL2l4Z2JlL2l4Z2JlX3g1NTAu
YyBiL2RyaXZlcnMvbmV0L2V0aGVybmV0L2ludGVsL2l4Z2JlL2l4Z2JlX3g1NTAuYwppbmRleCAx
OWI3NWNkLi5jZmM4MTRhIDEwMDY0NAotLS0gYS9kcml2ZXJzL25ldC9ldGhlcm5ldC9pbnRlbC9p
eGdiZS9peGdiZV94NTUwLmMKKysrIGIvZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50ZWwvaXhnYmUv
aXhnYmVfeDU1MC5jCkBAIC0yOTE1LDcgKzI5MTUsNyBAQCBzdGF0aWMgY29uc3Qgc3RydWN0IGl4
Z2JlX21hY19vcGVyYXRpb25zIG1hY19vcHNfWDU1MEVNX3ggPSB7CiAJLmFjcXVpcmVfc3dmd19z
eW5jCT0gJml4Z2JlX2FjcXVpcmVfc3dmd19zeW5jX1g1NTBlbSwKIAkucmVsZWFzZV9zd2Z3X3N5
bmMJPSAmaXhnYmVfcmVsZWFzZV9zd2Z3X3N5bmNfWDU1MGVtLAogCS5pbml0X3N3Zndfc3luYwkJ
PSAmaXhnYmVfaW5pdF9zd2Z3X3N5bmNfWDU0MCwKLQkuc2V0dXBfZmMJCT0gTlVMTCwgLyogZGVm
aW5lZCBsYXRlciAqLworCS5zZXR1cF9mYwkJPSBpeGdiZV9zZXR1cF9mY194NTUwZW0sCiAJLnJl
YWRfaW9zZl9zYl9yZWcJPSBpeGdiZV9yZWFkX2lvc2Zfc2JfcmVnX3g1NTAsCiAJLndyaXRlX2lv
c2Zfc2JfcmVnCT0gaXhnYmVfd3JpdGVfaW9zZl9zYl9yZWdfeDU1MCwKIH07Cg==
--001a1143e1987c777c05372285c7--
