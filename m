From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [REGRESSION] e1000e stopped working [MANUALLY BISECTED]
Date: Wed, 28 Jul 2010 18:10:58 -0700
Message-ID: <AANLkTinSOUcAxnqCo9YVVonhZ4sdC8iUK4r6F1+ayKef@mail.gmail.com>
References: <1277659633.2989.2.camel@localhost.localdomain>
	<1277659785.4028.1.camel@localhost.localdomain>
	<1277660638.3321.1.camel@localhost.localdomain>
	<1277660831.3321.3.camel@localhost.localdomain>
	<8DD2590731AB5D4C9DBF71A877482A90015918F40A@orsmsx509.amr.corp.intel.com>
	<1277745247.12841.1.camel@localhost.localdomain>
	<8DD2590731AB5D4C9DBF71A877482A90015918FAB6@orsmsx509.amr.corp.intel.com>
	<1277807529.19417.2.camel@localhost.localdomain>
	<EA929A9653AAE14F841771FB1DE5A1365FF4705C9D@rrsmsx501.amr.corp.intel.com>
	<1277938757.4138.3.camel@localhost.localdomain>
	<1278204106.21020.0.camel@localhost.localdomain>
	<1278283714.3444.1.camel@localhost.localdomain>
	<AANLkTin4sdPeExcNJkq4pfwIq0lcJuXtzTAACRW3JTFh@mail.gmail.com>
	<1278323885.5277.0.camel@localhost.localdomain>
	<1278950178.17933.2.camel@localhost.localdomain>
	<EA929A9653AAE14F841771FB1DE5A1365FF4A9B949@rrsmsx501.amr.corp.intel.com>
	<1278981483.23017.4.camel@localhost.localdomain>
	<EA929A9653AAE14F841771FB1DE5A1365FF4B05AF9@rrsmsx501.amr.corp.intel.com>
	<1279150380.7810.2.camel@localhost.localdomain>
	<1279220266.4411.2.camel@localhost.localdomain>
	<EA929A9653AAE14F841771FB1DE5A1365FF4B860D9@rrsmsx501.amr.corp.intel.com>
	<1279220945.4411.6.camel@localhost.localdomain>
	<1279308358.3979.0.camel@localhost.localdomain>
	<EA929A9653AAE14F841771FB1DE5A1365FFE1B19CD@rrsmsx501.amr.corp.intel.com>
	<1279374897.8428.5.camel@localhost.localdomain>
	<1280103959.2589.2.camel@localhost.localdomain>
	<1280300683.8250.2.camel@maxim-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Pieper, Jeffrey E" <jeffrey.e.pieper@intel.com>
To: Maxim Levitsky <maximlevitsky@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:37842 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751163Ab0G2BK7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jul 2010 21:10:59 -0400
Received: by iwn7 with SMTP id 7so5146038iwn.19
        for <netdev@vger.kernel.org>; Wed, 28 Jul 2010 18:10:58 -0700 (PDT)
In-Reply-To: <1280300683.8250.2.camel@maxim-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 28, 2010 at 00:04, Maxim Levitsky <maximlevitsky@gmail.com>=
 wrote:
> On Mon, 2010-07-26 at 03:25 +0300, Maxim Levitsky wrote:
>>
>> This commit, present in net-next, solves the problem:
>>
>> commit 1286950690f0f82ffa504e1e149ee3fdb4c51478
>> Author: Bruce Allan <bruce.w.allan@intel.com>
>> Date: =C2=A0 Mon Jul 26 03:19:38 2010 +0300
>>
>> =C2=A0 =C2=A0 e1000e: cleanup e1000_sw_lcd_config_ich8lan()
>>
>> =C2=A0 =C2=A0 Do not acquire and release the PHY unnecessarily for p=
arts that return
>> =C2=A0 =C2=A0 from this workaround without actually accessing the PH=
Y registers.
>>
>> =C2=A0 =C2=A0 Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
>> =C2=A0 =C2=A0 Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
>> =C2=A0 =C2=A0 Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.c=
om>
>> =C2=A0 =C2=A0 Signed-off-by: David S. Miller <davem@davemloft.net>
>>
>>
>>
>>
>> Also, the above patch is part of whole series of patches with scary =
descriptions (that is these fix bugs).
>> If I were you I would send them to Linus for 2.6.35 inclusion too.
>>
>> Best regards,
>> =C2=A0 =C2=A0 =C2=A0 Maxim Levitsky
>>
>>
>>
> ping
>

Sorry for the delayed response.  I am working on the issue.  Here is
the problem I am having, the patch that fixes the issue you are seeing
is fairly large and is a cleanup to the ich8 function, which as it
stands now, would not be accepted into net-2.6 tree this late into the
-rc cycle.  So, what I looking at is, what specifically fixed the
issue you are seeing that resides in that patch, and come up with a
smaller (acceptable) patch that I can submit to net-2.6 now to resolve
your issue.

I have dedicated most of this evening to finding a resolution to your
issue that will be acceptable for the net-2.6 tree.  As you noted,
there were several patches before this particular commit that may play
some part in the resolution as well, and that is what I will be
looking into.  I greatly appreciate the hard work you have done to
help us resolve this issue, and will make sure you get credit for any
solution I put together to resolve this issue.

--=20
Cheers,
Jeff
