From: "Dushan Tcholich" <dusanc@gmail.com>
Subject: Re: ksoftirqd high cpu load on kernels 2.6.24 to 2.6.27-rc1-mm1
Date: Mon, 4 Aug 2008 22:37:30 +0200
Message-ID: <a08621850808041337k1d1deb6fk78098d9fcd4930dd@mail.gmail.com>
References: <fa.wTMiBcGRgw2fBtdHwtX7y0lkc8s@ifi.uio.no>
	 <48975BD3.6040709@shaw.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, romieu@fr.zoreil.com,
	netdev@vger.kernel.org
To: "Robert Hancock" <hancockr@shaw.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.182]:7530 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763088AbYHDUhb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2008 16:37:31 -0400
Received: by wa-out-1112.google.com with SMTP id j37so1580845waf.23
        for <netdev@vger.kernel.org>; Mon, 04 Aug 2008 13:37:30 -0700 (PDT)
In-Reply-To: <48975BD3.6040709@shaw.ca>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

On Mon, Aug 4, 2008 at 9:43 PM, Robert Hancock <hancockr@shaw.ca> wrote:
> Dushan Tcholich wrote:
>>
>> Hello
>>
>> This is my first bugreport on LKML so please be patient :)
>>
>> top always shows me that ksoftirqd usualy gets around 8%CPU, it
>> changes between 6 and 10%.
>> It's sometimes ksoftirqd/0 sometimes /1, differs on the reboot but
>> doesn't change during work.
>> I noticed it because it had very high time+, 500hours or so.
>> I reproduced these problems with kernels 2.6.24 .25 and .27-rc1-mm1. I
>> don't remember that this happened during .22 and .23 kernels, but I
>> can check again if it's necessary.
>> Timer freq is 1000Hz
>>
>> What I tried without changes with help from ##kernel:
>> 1. built kernel without kvm;
>> 2. disconnected all usb hw except mouse;
>> 3. run glxgears which consumed 98% CPU and ksoftirqd  2%;
>> 4. Tried to stress disk subsystem by copying a lot of small files on
>> the same partition:
>> time cp -R /usr/portage/* /tmp/1
>> real 2m17.530s
>> user 0m0.764s
>> sys 0m18.596s
>>
>> it was 127507 items 1.5GB, but just pdflush jumped to 14% from time to
>> time;
>> 5. disabled serial port in BIOS because my UPS was connected to it,
>> and I suspected that it was maybe polling too much;
>> 6. disconnected eth cable
>> 7. tried googling but all I found is that some people had similar
>> problem. Some TV cards were the culprit but I don't have that HW.
>>
>> If you need any more data please cc me as I'm not subscribed
>
> It would be useful to try running oprofile on an otherwise idle system and
> see where it reports the CPU time is being used..
>
I googled a little and found out that oprofile is a little above my head.
So as I thought that some driver or HW might be responsible for this I
tried to disable various onboard HW and found out that if I disable
onboard ethernet problem dissapears, so now I've added netdev and
maintainer of R8169 driver to cc.

Thanks
Dushan
