From: Po-Yu Chuang <ratbert.chuang@gmail.com>
Subject: Re: [PATCH v3] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Fri, 21 Jan 2011 15:06:37 +0800
Message-ID: <AANLkTimwcWtmftfwXBFfFG+bUNxNSJqNVnyvU_oWsyNL@mail.gmail.com>
References: <1295256060-2091-1-git-send-email-ratbert.chuang@gmail.com>
 <1295537418-2057-1-git-send-email-ratbert.chuang@gmail.com>
 <1295550009.28001.59.camel@Joe-Laptop> <AANLkTi=b9ma=xV1ovbJmy94BrDT696VR4OcyR9vqwGtB@mail.gmail.com>
 <1295592411.6795.10.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bhutchings@solarflare.com, eric.dumazet@gmail.com,
	dilinger@queued.net
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:35624 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752324Ab1AUHG7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jan 2011 02:06:59 -0500
In-Reply-To: <1295592411.6795.10.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Joe,

On Fri, Jan 21, 2011 at 2:46 PM, Joe Perches <joe@perches.com> wrote:
> On Fri, 2011-01-21 at 13:03 +0800, Po-Yu Chuang wrote:
>> > Is it useful to retry the NORXBUF case?
>> The idea is that if I miss packet finished interrupts (then rx buffe=
rs used up),
>> I should retrieve the received packets ASAP to free buffers to HW.
>> Maybe this is really unnecessary.
>> I am not quite sure, but I'll do your advice now.
>
> I wasn't giving advice, just asking a question.
> Your concept makes sense to me.

I see. So I will leave it as is.

>> >> + =C2=A0 =C2=A0 if (status & FTMAC100_INT_NORXBUF) {
>> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* RX buffer unavaila=
ble */
>> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (net_ratelimit())
>> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 netdev_info(netdev, "INT_NORXBUF\n");
>> >> +
>> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 netdev->stats.rx_over=
_errors++;
>> >> + =C2=A0 =C2=A0 }
>> >
>> > Perhaps this "if (status & FTMAC100_INT_NORXBUF)" block should be
>> > moved into the test block above it before the retry?
>>
>> Since status is not changed in the function, it does not matter wher=
e
>> the test is.
>> But I agree that it is better to handle error cases earlier.
>
> This wasn't so much a handle error case early, but
> a suggestion that
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (status & (foo | bar)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0...
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (status & bar) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0...
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> should be
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (status & (foo | bar)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0...
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (status & b=
ar) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0...
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> so that when the first test fails, a known
> subset of the first test isn't tested again.

Understand. Thanks.

best regards,
Po-Yu Chuang
