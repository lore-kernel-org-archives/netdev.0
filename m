From: Adam Katz <adamkatz0@gmail.com>
Subject: Re: libpcap and tc filters
Date: Mon, 4 Jul 2011 15:01:34 +0300
Message-ID: <CAA0qwj70-qUQ+6NL=2LP05TyMN99MdL1BF8tko+v=DhdyjZjJQ@mail.gmail.com>
References: <CAA0qwj6fWJFVCDW9M9jZhvQnSTy=Pnyp0AhWFYT8FOiroq7C=Q@mail.gmail.com>
	<1309777908.26180.1.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:46491 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295Ab1GDMBe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2011 08:01:34 -0400
Received: by iyb12 with SMTP id 12so4389410iyb.19
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2011 05:01:34 -0700 (PDT)
In-Reply-To: <1309777908.26180.1.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, I just tried this:

I've opened www.example.com using a browser while capturing with
wireshark. TC placed all port 80 packets into the 1:1 as required. I
then physically plugged the nic to a different socket, one that isn't
connected to the internet (i did this so I wont get any server
responses to the packets i'm sending) and then I replayed the capture
of me opening www.example.com

The second time, none of the packets ended up in 1:1 - they all went
to the default class despite being the EXACT same traffic.

On Mon, Jul 4, 2011 at 2:11 PM, jamal <hadi@cyberus.ca> wrote:
>
> Capture tcpdump for both scenario that works and one
> that doesnt.
> Make sure the filters match your failing scenario.
>
> cheers,
> jamal
>
> On Mon, 2011-07-04 at 10:38 +0300, Adam Katz wrote:
>> Hi Everyone
>>
>> I'm sorry for littering the mailing list with this question, but no
>> other place could help me..
>>
>> I'm attempting to use tc to shape traffic sent using libpcap, I'm
>> doing this for a research project. I have a classful scheduler with
>> several classes, to this scheduler I attach a few filters based on
>> destination tcp ports.
>>
>> My problem is this: When sending packets using a normal userland
>> socket, the filters work and I see the appropriate traffic entering
>> the right class. BUT when sending packets with libpcap, all packets
>> end up in the scheduler's default band as if the filters simply refu=
se
>> to work.
>>
>> Can anyone suggest a solution?
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
>
>
