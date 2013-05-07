From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: 3.8.4 kernel
Date: Tue, 7 May 2013 09:20:14 -0700
Message-ID: <CAErSpo44-f4UdXxO5MdwVg09LFABwFQ320gG8v8jHcYh=5gqvA@mail.gmail.com>
References: <5153620E.4010608@gmail.com> <CAErSpo6w+tTbwJ7Qinpd0Vx20q5cm2gMvqzE1Do+2=G3b8rcHA@mail.gmail.com>
 <CAErSpo6iwM2r8b-aoiBPjQpkdpcfgLiO+WkpiM1wFsDhxuSXPg@mail.gmail.com>
 <CAErSpo68AWCGWQHKgoKuD-QFA0b+jbCRf7T_PzzKoUsVwdZHOg@mail.gmail.com> <157393863283F442885425D2C45428564F219B3B@nasanexd02f.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Joseph A. Millikan" <josephamillikan@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Ren, Cloud" <cjren@qca.qualcomm.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: "Huang, Xiong" <xiong@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:48644 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752496Ab3EGQUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 12:20:35 -0400
Received: by mail-ob0-f169.google.com with SMTP id tb18so715523obb.28
        for <netdev@vger.kernel.org>; Tue, 07 May 2013 09:20:35 -0700 (PDT)
In-Reply-To: <157393863283F442885425D2C45428564F219B3B@nasanexd02f.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[+cc Eric because he made a change (69b08f62e17) that apparently
exposes driver bugs]

On Mon, May 6, 2013 at 7:51 PM, Huang, Xiong <xiong@qca.qualcomm.com> wrote:
>> >
>> > Did this ever get resolved?
>>
>> I opened https://bugzilla.kernel.org/show_bug.cgi?id=57681 to keep track of
>> this and attached the dmesg logs you collected.  If you have a chance, could you
>> also collect and attach the output of "lspci -vv"
>> (any kernel is fine for this).
>>
>> I don't see anything obvious wrong, at least from the PCI side.  Maybe the atl1c
>> guys will have some ideas.
>>
>
> Hi Bjorn and All
>      This issue should be same as bug https://bugzilla.kernel.org/show_bug.cgi?id=54021
>      I didn't find any abnormal info from the log and the PHY link is stable as well :(
>      Is it related to the network manager ?

I looked at bug #54021 and it does look similar.  It doesn't look like
it has been resolved.

http://forums.gentoo.org/viewtopic-t-949168-highlight-.html is another
report that looks very similar.  BigE there has a Lenovo G570 that has
both wireless and wired networking.  If BigE disables wireless with a
hardware switch before booting, it seems to avoid the atl1c wired
networking issue.  That's not a fix, of course, but it might be a clue
and a temporary workaround until we have a real solution.

Joseph, if there's no hardware switch for the wireless on your G770,
you can probably still take wireless out of the picture by removing or
renaming the bcma module (look in
/lib/modules/.../kernel/drivers/bcma/), then rebooting.

Xiong, do you have a specific network manager-related test that Joseph
could perform?  I don't want to burden Joseph with a lot of debugging
because he's currently happy with 3.6.11 and testing is pretty
disruptive in his environment.

Bjorn
