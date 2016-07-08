From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH] (resend) ixgbe: always initialize
	setup_fc
Date: Fri, 8 Jul 2016 00:18:19 +0000
Message-ID: <87618083B2453E4A8714035B62D679925066EACF@FMSMSX105.amr.corp.intel.com>
References: <CAE2NFgXe4uPT1WDVzSq_rr54XA7xDNuedoBgHdtd2_WekNQZ+A@mail.gmail.com>
 <038AE347-E85C-4738-BC91-C8C16AE88620@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>,
	Patrick McLean <patrickm@gaikai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:20016 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753187AbcGHASV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 20:18:21 -0400
In-Reply-To: <038AE347-E85C-4738-BC91-C8C16AE88620@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
>Behalf Of Rustad, Mark D
>Sent: Wednesday, July 06, 2016 4:01 PM
>To: Patrick McLean <patrickm@gaikai.com>
>Cc: netdev <netdev@vger.kernel.org>; intel-wired-lan <intel-wired-
>lan@lists.osuosl.org>
>Subject: Re: [Intel-wired-lan] [PATCH] (resend) ixgbe: always initialize
>setup_fc
>
>Patrick McLean <patrickm@gaikai.com> wrote:
>
>> Gmail mangled my first message, sorry about that. Second attempt.
>>
>> In ixgbe_init_mac_link_ops_X550em, the code has a special case for
>> backplane media type, but does not fall through to the default case,
>> so the setup_fc never gets initialized. This causes a panic when it
>> later tries to set up the card, and the kernel dereferences the null
>> pointer.
>>
>> This patch lets the the function fall through, which initialized
>> setup_fc properly.
>
>I don't think that this is the right fix. My memory is that fc autoneg is

setup_fc() does not configure FC autoneg and it should always be set.

I posted an alternative patch that simply sets setup_fc at the beginning of 
the function. The fall-through in the switch statement is not a good solution
because it won't work in case we need to add another case.

http://patchwork.ozlabs.org/patch/646228/

Thanks,
Emil
