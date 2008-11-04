From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: r8169 MAC addresses broken
Date: Tue, 04 Nov 2008 19:49:42 +0100
Message-ID: <49109946.7020702@redhat.com>
References: <490380C8.6070003@simon.arlott.org.uk>	<4903947A.3060206@gmail.com>	<20081025223443.GA30913@electric-eye.fr.zoreil.com>	<4904A7C5.7090801@gmail.com>	<20081026174654.GB24790@electric-eye.fr.zoreil.com>	<4906E4BE.9050304@gmail.com> <m3mygozvd4.fsf@maximus.localdomain> <490718C7.3010501@gmail.com> <490EBE83.7030309@redhat.com> <490F0FCF.4060905@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Halasa <khc@pm.waw.pl>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Simon Arlott <simon@fire.lp0.eu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Arjan van de Ven <arjan@infradead.org>
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:45039 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751251AbYKDSuO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2008 13:50:14 -0500
In-Reply-To: <490F0FCF.4060905@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Slaby wrote:
> On 11/03/2008 10:04 AM, Ivan Vecera wrote:
>> Jiri Slaby wrote:
>>> On 10/28/2008 02:45 PM, Krzysztof Halasa wrote:
>>>> Jiri Slaby <jirislaby@gmail.com> writes:
>>>>
>>>>>> Same thing if you unplug the battery ?
>>>>> Thanks, now it seems to be OK.
>>>> Well, perhaps reverting that patch was a bit premature?
>>> No, it helped after reverting that patch. I think we don't want defunct 2.6.28
>>> with these nics.
>> I cannot agree.
> 
> You want defunct r8169 in 2.6.28? Or cannot agree with what?
> 
>> IMO the problem was in the first version of the patch that didn't
>> check for invalid (zeroed) MAC address. In this case is necessary to power-off (desktop
>> case) or unplug the battery (notebook case).
> 
> I see no updated patch in this thread to test -- am I missing something?
Francois has fix for this problem (zeroed MAC address) in his repository:
http://git.kernel.org/?p=linux/kernel/git/romieu/netdev-2.6.git;a=commitdiff;h=9b1abbccf53ef1a1213b159d56257b535c599f07

snippet:
...
-       /* Write MAC address */
-       rtl_rar_set(tp, mac);
+       if (is_valid_ether_addr(mac))
+               rtl_rar_set(tp, mac);
...


When MAC only zeros then it is not assigned. Pulling this commit is better than reverting whole patch.

Ivan
