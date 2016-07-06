From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v4 01/29] bluetooth: Switch SMP to crypto_cipher_encrypt_one()
Date: Wed, 6 Jul 2016 06:17:30 -0700
Message-ID: <CALCETrXg1z0J0Ub7vPfNO4Tt-q7z=PNc6W8d8iSAV3FBmoXphA@mail.gmail.com>
References: <cover.1466974736.git.luto@kernel.org> <264af59a3060c2bc2a725cfc66a8fa68219d1c4a.1466974736.git.luto@kernel.org>
 <8C5360E3-94EE-4869-B9B9-AF9D41B5A3AC@holtmann.org> <20160627085403.GA26865@gmail.com>
 <2833CC26-7306-4803-A5DB-4CBECCF35C08@holtmann.org> <CALCETrVx6PDUb+5S9eYuB+Dhu2VEkz-iz=hpRJdzxRfXypwK8A@mail.gmail.com>
 <73C272C5-ECDB-4508-B8D3-1F54D5E8E6AB@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ingo Molnar <mingo@kernel.org>, Andy Lutomirski <luto@kernel.org>,
	X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-arch <linux-arch@vger.kernel.org>,
	Borislav Petkov <bp@alien8.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Kees Cook <keescook@chromium.org>,
	Brian Gerst <brgerst@gmail.com>,
	"kernel-hardening@lists.openwall.com"
	<kernel-hardening@lists.openwall.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Josh Poimboeuf <jpoimboe@redhat.com>,
	Jann Horn <jann@thejh.net>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	"Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f42.google.com ([209.85.213.42]:35497 "EHLO
	mail-vk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754200AbcGFNRv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 09:17:51 -0400
Received: by mail-vk0-f42.google.com with SMTP id v6so33517836vkb.2
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 06:17:50 -0700 (PDT)
In-Reply-To: <73C272C5-ECDB-4508-B8D3-1F54D5E8E6AB@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 4, 2016 at 10:56 AM, Marcel Holtmann <marcel@holtmann.org> wrote:
> Hi Andy,
>
>>>>>> SMP does ECB crypto on stack buffers.  This is complicated and
>>>>>> fragile, and it will not work if the stack is virtually allocated.
>>>>>>
>>>>>> Switch to the crypto_cipher interface, which is simpler and safer.
>>>>>>
>>>>>> Cc: Marcel Holtmann <marcel@holtmann.org>
>>>>>> Cc: Gustavo Padovan <gustavo@padovan.org>
>>>>>> Cc: Johan Hedberg <johan.hedberg@gmail.com>
>>>>>> Cc: "David S. Miller" <davem@davemloft.net>
>>>>>> Cc: linux-bluetooth@vger.kernel.org
>>>>>> Cc: netdev@vger.kernel.org
>>>>>> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
>>>>>> Acked-and-tested-by: Johan Hedberg <johan.hedberg@intel.com>
>>>>>> Signed-off-by: Andy Lutomirski <luto@kernel.org>
>>>>>> ---
>>>>>> net/bluetooth/smp.c | 67 ++++++++++++++++++++++-------------------------------
>>>>>> 1 file changed, 28 insertions(+), 39 deletions(-)
>>>>>
>>>>> patch has been applied to bluetooth-next tree.
>>>>
>>>> Sadly carrying this separately will delay the virtual kernel stacks feature by a
>>>> kernel cycle, because it's a must-have prerequisite.
>>>
>>> I can take it back out, but then I have the fear the the ECDH change to use KPP for SMP might be the one that has to wait a kernel cycle. Either way is fine with me, but I want to avoid nasty merge conflicts in the Bluetooth SMP code.
>>
>> Nothing goes wrong if an identical patch is queued in both places,
>> right?  Or, if you prefer not to duplicate it, could one of you commit
>> it and the other one pull it?  Ingo, given that this is patch 1 in the
>> series and unlikely to change, if you want to make this whole thing
>> have a separate branch in -tip, this could live there for starters.
>> (But, if you do so, please make sure you base off a very new copy of
>> Linus' tree -- the series is heavily dependent on the thread_info
>> change he applied a few days ago.)
>
> so what are doing now? I take this back out or we keep it in and let git deal with it when merging the trees?
>

Unless Ingo says otherwise, let's let git deal with it.
