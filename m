From: Michal Kazior <michal.kazior@tieto.com>
Subject: Re: Throughput regression with `tcp: refine TSO autosizing`
Date: Wed, 4 Feb 2015 13:53:11 +0100
Message-ID: <CA+BoTQ=qmCZz4CmSOvCOzMLowrDEG12XBffkTcYxjGqVD9604g@mail.gmail.com>
References: <CA+BoTQkVu23P3EOmY_Q3E1GJnWsyF==Pawz4iPOS_Bq5dvfO5Q@mail.gmail.com>
	<1422537297.21689.15.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQk2xT-8DqPuiiKG+kHAjLPrj8F9dLTb-rcGhvMq0u_2Qw@mail.gmail.com>
	<1422628835.21689.95.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQkV+mOZfe_Niz5101sMQeaV6muKCsShptjGQ1AgOHqqoQ@mail.gmail.com>
	<1422903136.21689.114.camel@edumazet-glaptop2.roam.corp.google.com>
	<1422926330.21689.138.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQkMikA8wxm1ce2DkKhPB0HiKeAqT7f+sQ=91W40z=X0Rg@mail.gmail.com>
	<1422973660.907.10.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQmvUuFdfYF=wVMYxrf_nQZB5GCV=LvDZVvfs-3hAE4WKw@mail.gmail.com>
	<1423051045.907.108.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQ=BDcQ779uKCuX+f40=4npXVF4MTQnpjKimNYAxPsxBoQ@mail.gmail.com>
	<1423053531.907.115.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	eyalpe@dev.mellanox.co.il
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f181.google.com ([74.125.82.181]:55753 "EHLO
	mail-we0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965680AbbBDMxN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 07:53:13 -0500
Received: by mail-we0-f181.google.com with SMTP id k48so1522317wev.12
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 04:53:12 -0800 (PST)
In-Reply-To: <1423053531.907.115.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4 February 2015 at 13:38, Eric Dumazet <eric.dumazet@gmail.com> wrot=
e:
> On Wed, 2015-02-04 at 13:22 +0100, Michal Kazior wrote:
>> On 4 February 2015 at 12:57, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
>
>>
>> > To disable gso you would have to use :
>> >
>> > ethtool -K wlan1 gso off
>>
>> Oh, thanks! This works. However I can't turn it on:
>>
>> ; ethtool -K wlan1 gso on
>> Could not change any device features
>>
>> ..so I guess it makes no sense to re-run tests because:
>>
>> ; ethtool -k wlan1 | grep generic
>>         tx-checksum-ip-generic: on [fixed]
>> generic-segmentation-offload: off [requested on]
>> generic-receive-offload: on
>>
>> And this seems to never change.
>
> GSO requires SG (Scatter Gather)
>
> Are you sure this hardware has no SG support ?

The hardware itself seems to be capable. The firmware is a problem
though. I'm also not sure if mac80211 can handle this as is. No 802.11
driver seems to support SG except wil6210 which uses cfg80211 and
netdevs directly.


Micha=C5=82
