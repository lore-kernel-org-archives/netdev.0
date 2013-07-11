From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net v2] gso: Update tunnel segmentation to support Tx
 checksum offload
Date: Thu, 11 Jul 2013 00:45:19 -0700
Message-ID: <CALnjE+rA4kPiwemZ+A0GfSMw8OsS=ssRw0S_1i75jyF2HB2D0Q@mail.gmail.com>
References: <20130711000015.13134.17801.stgit@ahduyck-hc1.jf.intel.com>
	<1373503334.4600.27.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, stephen@networkplumber.org,
	joseph.gasparakis@intel.com, jesse@nicira.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog105.obsmtp.com ([74.125.149.75]:58487 "HELO
	na3sys009aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755602Ab3GKHpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 03:45:21 -0400
Received: by mail-qa0-f50.google.com with SMTP id l18so4047927qak.16
        for <netdev@vger.kernel.org>; Thu, 11 Jul 2013 00:45:19 -0700 (PDT)
In-Reply-To: <1373503334.4600.27.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 10, 2013 at 5:42 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2013-07-10 at 17:05 -0700, Alexander Duyck wrote:
>> This change makes it so that the GRE and VXLAN tunnels can make use of Tx
>> checksum offload support provided by some drivers via the hw_enc_features.
>> Without this fix enabling GSO means sacrificing Tx checksum offload and
>> this actually leads to a performance regression as shown below:
>>
>>             Utilization
>>             Send
>> Throughput  local         GSO
>> 10^6bits/s  % S           state
>>   6276.51   8.39          enabled
>>   7123.52   8.42          disabled
>
> While testing your patch, I discovered TSO support is completely broken
> on GRE, using bnx2x testbed.
>
> Oh well.
>
> It seems Nicira guys do not test a lot their patches.
>
>
Nice speculation ;)

I did some digging and found following commit causing problem with GRE
TSO on bnx setup.

c957d09ffda417f6c8e3d1f10e2b05228607d6d7 is the first bad commit
commit c957d09ffda417f6c8e3d1f10e2b05228607d6d7
Author: Yuval Mintz <yuvalmin@broadcom.com>
Date:   Tue Jun 25 08:50:11 2013 +0300

    bnx2x: Remove sparse and coccinelle warnings

    This patch solves several sparse issues as well as an unneeded semicolon
    found via coccinelle.

    Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
    Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
    Signed-off-by: Ariel Elior <ariele@broadcom.com>
    Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
