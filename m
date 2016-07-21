From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: WAS ( Re: [PATCH net-next 1/1] net_sched: Introduce skbmod action
Date: Thu, 21 Jul 2016 03:27:30 -0400
Message-ID: <742d87f4-b1af-ff02-93a9-bdcd369492af@mojatatu.com>
References: <1468744884-8246-1-git-send-email-jhs@emojatatu.com>
 <20160718041933.GB36253@ast-mbp.thefacebook.com>
 <578C7C5C.2070804@mojatatu.com> <578CA4EB.7060703@iogearbox.net>
 <578CAA96.2090501@mojatatu.com> <578E2960.7080709@iogearbox.net>
 <578E3172.9020601@mojatatu.com> <578E414C.1080501@iogearbox.net>
 <CAM_iQpWX5HT_yF3guCbQLMo2GSVGA8BTcJ3_bucHrnBrMQbjqw@mail.gmail.com>
 <578EC467.2010808@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Daniel Borkmann <daniel@iogearbox.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:38355 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751493AbcGUH1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 03:27:33 -0400
Received: by mail-wm0-f45.google.com with SMTP id o80so13094252wme.1
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 00:27:33 -0700 (PDT)
In-Reply-To: <578EC467.2010808@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-07-19 08:23 PM, Daniel Borkmann wrote:
> On 07/19/2016 08:04 PM, Cong Wang wrote:
>> On Tue, Jul 19, 2016 at 8:03 AM, Daniel Borkmann
>> <daniel@iogearbox.net> wrote:
>>> On 07/19/2016 03:56 PM, Jamal Hadi Salim wrote:
>>> [...]

[..]
>> I don't think so. 1) checksum is supposed to be done by csum action
>> rather than pedit (or skbmod if it matters), 2) csum action currently
>> already handles that correctly for both egress and ingress: 2a)
>> CHECKSUM_COMPLETE is meaningless on egress; 2b) it forces
>> CHECKSUM_COMPLETE to be CHECKSUM_NONE on ingress
>> and it is correctly respected.
>
> Ahh, right, so it redoes entire csums when worst-case changing one byte
> only, since it cannot know what other actions like pedit did previously.
 >
> But it also means for your l2 mac addr changes to force a CHECKSUM_COMPLETE
> into CHECKSUM_NONE with csum action that you need to call into one of the
> l3/l4 helpers as far as I see.


Forgot about csum which would work with pedit - didnt quiet parse what
you are saying above though:
does changing MAC address require changing to CHECKSUM_NONE? If yes,
then seems like i need to send a patch for act_ife as well to make in
the spirit of mirred?

Having said all that:
This discussion now has gone past the original patch submission.
I really want to see this patch go in and dont want to get Dave to
review all these side comments - for this reason I changed the subject.

cheers,
jamal
