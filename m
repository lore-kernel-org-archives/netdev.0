From: Ben Greear <greearb@candelatech.com>
Subject: Re: Slow ramp-up for single-stream TCP throughput on 4.2 kernel.
Date: Mon, 05 Oct 2015 06:35:53 -0700
Message-ID: <56127CB9.1020100@candelatech.com>
References: <560F1672.5000602@candelatech.com>		<560F1F74.9010207@candelatech.com>		<CADVnQym4U_dVVRdOVhORvVabwFjSHTQJ_LbbbYtzWVu0=mAp_A@mail.gmail.com>		<56105AD2.7070906@candelatech.com>	 <CADVnQynKmhrpD63sF5aWPYo9f8L3wOMuEyACBnTdkzQQ=D1_uA@mail.gmail.com>	 <56115C68.1080803@candelatech.com> <1443979705.32531.71.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	netdev <netdev@vger.kernel.org>,
	ath10k <ath10k@lists.infradead.org>,
	Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:36117 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752111AbbJENfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 09:35:55 -0400
In-Reply-To: <1443979705.32531.71.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/04/2015 10:28 AM, Eric Dumazet wrote:
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

I ran some more tests this morning.  The first bump in the graph
has the setting above.  Seems to work pretty good.

The second is using RENO.  Also good, and a small bit of higher over-all
throughput (about 555-560Mbps of RX throughput).

Third is 'highspeed'.  It ramps up quickly, but seems a bit more jagged, and
not quite as fast as RENO.

>
> Or try
>
> echo 40 >/sys/module/tcp_cubic/parameters/hystart_low_window

The last graph is this setting (with hystart_detect set back to 3,
which was the default on my system).

This is better than stock cubic, but it still is awful compared
to the others.

http://www.candelatech.com/downloads/tcp_cong_ath10k_2.pdf

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
