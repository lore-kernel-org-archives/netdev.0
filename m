From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 7/7] bnx2x: expose HW RX VLAN stripping toggle
Date: Tue, 30 Aug 2011 22:08:41 +0200
Message-ID: <CAHXqBFJH1v614r3GLxn7wDsZgTCK6H=GNu9S15sBtZ-FsmJAwg@mail.gmail.com>
References: <1314714646-3642-1-git-send-email-mschmidt@redhat.com>
 <1314714646-3642-8-git-send-email-mschmidt@redhat.com> <CAHXqBFLgTHvxL34eR1qX7nEmntyOBXYrg-7LQvW=d8dnDpbhWg@mail.gmail.com>
 <4E5D3A43.1060202@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, vladz@broadcom.com, dmitry@broadcom.com,
	eilong@broadcom.com
To: Michal Schmidt <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:49596 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756234Ab1H3UJC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 16:09:02 -0400
Received: by gwaa12 with SMTP id a12so5908095gwa.19
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 13:09:01 -0700 (PDT)
In-Reply-To: <4E5D3A43.1060202@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 30 sierpnia 2011 21:30 u=BFytkownik Michal Schmidt
<mschmidt@redhat.com> napisa=B3:
> On 08/30/2011 08:27 PM, Micha=B3 Miros=B3aw wrote:
>> It seems rather convoluted and unnecessary that you mirror
>> NETIF_F_HW_VLAN_RX in bp->flags
> This mirroring is for the benefit of functions called indirectly from
> bnx2x_set_features(). They cannot look at dev->features for
> NETIF_F_HW_VLAN_RX because it's not set before ->ndo_set_features() r=
eturns.

You can cheat in ndo_set_features in this case. Just set/clear
NETIF_F_HW_VLAN_RX bit in dev->features before you call those
functions (but please leave a comment there explaining why!). This is
allowed because if ndo_set_features fails it needs to fix
dev->features itself, and if it succeeds dev->features will be
replaced with exactly what was passed to ndo_set_features. So, unless
you need to check whether the VLAN stripping state changed in those
functions, then you can get rid of this copy.

>> and then also in fp->flags. =A0Are the
>> fp->flags strictly mirroring hardware state (as in: there is no way
>> the states can differ in any point in time where the flags are
>> tested)?
> Yes. This is the purpose of the second mirroring of the flag.
>> For this to be true, the two functions above need to be
>> called only without releasing a lock between them that is also taken
>> by receive handler.
> The flag propagates from bp->flags to fp->flags between unloading and
> reloading the NIC. The receive handler cannot run at the time.
>> Isn't there a flag in the rx descriptor of a
>> packet that says if VLAN was stripped? (All that flag keeping would =
be
>> unnecessary then.)
> There is no such flag, AFAIK.

Thanks for explanation!

Best Regards,
Micha=B3 Miros=B3aw
