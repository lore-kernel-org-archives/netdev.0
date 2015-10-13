From: =?UTF-8?Q?J=C3=B6rg_Pommnitz?= <j.pommnitz@gmail.com>
Subject: Re: Some ICMP-Reply messages don't arrive in User Space in recent Kernels
Date: Tue, 13 Oct 2015 15:22:35 +0200
Message-ID: <CAEvAWuHfM5m+W=gskdGkxLbSMz+VBA40=WJgBdFgUWP745HZCw@mail.gmail.com>
References: <CAEvAWuHSwA0=j_YDbowA56eCx10sJPm5KkveneSVhBQHNKY_zg@mail.gmail.com>
	<1444742292.1855606.408914113.79C7B013@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:35902 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932099AbbJMNWh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 09:22:37 -0400
Received: by lbcao8 with SMTP id ao8so19745360lbc.3
        for <netdev@vger.kernel.org>; Tue, 13 Oct 2015 06:22:35 -0700 (PDT)
In-Reply-To: <1444742292.1855606.408914113.79C7B013@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes,
thanks for your reply. It was indeed rp_filter (found it myself). What
changed were the default settings in Ubuntu (07.04 to 14.04).

Regards
  Joerg

2015-10-13 15:18 GMT+02:00 Hannes Frederic Sowa <hannes@stressinduktion=
=2Eorg>:
> On Tue, Oct 13, 2015, at 08:47, J=C3=B6rg Pommnitz wrote:
>> Hello all,
>> I'm moving an application from 2.6.23 (yes, it's ancient; that's why
>> we are moving) to 3.18LTS. The application monitors multiple network
>> links to the same target with ping packets. The different links are
>> selected either by their next hop router (Ethernet) or the network
>> interface (Point-to-Point links, aka cellular data).
>> To force different routes to the same target, the outgoing packets a=
re
>> tagged with different firewall marks. Then I'm using routing rules t=
o
>> select different routing tables with different routes for the same
>> target.
>> The outgoing path works perfectly fine in both, 2.6.23 and 3.18.
>> However, the same is not true for the incoming ICMP replies. They ar=
e
>> incoming; I see them with tcpdump. But some packets do not get
>> delivered to user space in 3.18. I'm not 100% sure, but I think this
>> happens if there is no "normal" route to the ping target, e.g. the
>> source address of the ICMP replies. This looks like some kind of
>> misguided ingress filtering that keeps packets out if a normal routi=
ng
>> lookup fails.
>>
>> Am I on the right track? If so, is there a way to disable this
>> filtering? If not, what could cause this changed behaviour?
>
> Did you disable rp_filter? Sounds like it, but 2.6.23 also had it
> activated by default, so maybe you missed the option in sysctl.conf.
>
> Bye,
> Hannes
