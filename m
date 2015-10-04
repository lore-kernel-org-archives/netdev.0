From: Yuchung Cheng <ycheng@google.com>
Subject: Re: Slow ramp-up for single-stream TCP throughput on 4.2 kernel.
Date: Sun, 4 Oct 2015 12:33:04 -0700
Message-ID: <CAK6E8=fjq-zFBeAE+XRskEf0uRuLk+AU25fOOK8PkOgXK9EaQQ@mail.gmail.com>
References: <560F1672.5000602@candelatech.com> <560F1F74.9010207@candelatech.com>
 <CADVnQym4U_dVVRdOVhORvVabwFjSHTQJ_LbbbYtzWVu0=mAp_A@mail.gmail.com>
 <56105AD2.7070906@candelatech.com> <CADVnQynKmhrpD63sF5aWPYo9f8L3wOMuEyACBnTdkzQQ=D1_uA@mail.gmail.com>
 <56115C68.1080803@candelatech.com> <1443979705.32531.71.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ben Greear <greearb@candelatech.com>,
	Neal Cardwell <ncardwell@google.com>,
	netdev <netdev@vger.kernel.org>,
	ath10k <ath10k@lists.infradead.org>,
	Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f46.google.com ([209.85.213.46]:35520 "EHLO
	mail-vk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751617AbbJDTdo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Oct 2015 15:33:44 -0400
Received: by vkao3 with SMTP id o3so85219133vka.2
        for <netdev@vger.kernel.org>; Sun, 04 Oct 2015 12:33:43 -0700 (PDT)
In-Reply-To: <1443979705.32531.71.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 4, 2015 at 10:28 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sun, 2015-10-04 at 10:05 -0700, Ben Greear wrote:
>
>> I guess I'll just stop using Cubic.  Any suggestions for another
>> congestion algorithm to use?  I'd prefer something that worked well
>> in pretty much any network condition, of course, and it has to work with
>> ath10k.
>>
>> We can also run some tests with 1G, 10G, ath10k, ath9k, and in conjunction
>> with network emulators and various congestion control algorithms.
>
> You could use cubic , but disable or tune HyStart, which is known to be
> problematic anyway.
>
> echo  0 >/sys/module/tcp_cubic/parameters/hystart_detect
>
> Or try
>
> echo 40 >/sys/module/tcp_cubic/parameters/hystart_low_window
Or if you truly don't want to use cubic, Reno would be my choice b/c
1) Cubic in mid-low BDP behaves like Reno (tcp friendly mode)
2) Reno has several recent stretched-ack fixes which may be useful in wireless

>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
