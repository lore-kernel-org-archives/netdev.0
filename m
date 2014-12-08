From: Jesse Gross <jesse@nicira.com>
Subject: Re: [ovs-discuss] kernel panic receiving flooded VXLAN traffic with OVS
Date: Mon, 8 Dec 2014 09:33:20 -0800
Message-ID: <CAEP_g=86QKL_Oxxj0mo8CZs8+fyBZuYw2fQTMGow_bSJbk+8AQ@mail.gmail.com>
References: <19014.1415325508@famine> <8549.1417657547@famine>
 <CAEP_g=_mfSCH1250ezx_h8_yM_4FzsYcsS6EnGi99AFoWO_MKw@mail.gmail.com> <CADmMkWdGhw3Rn3gMEtAV8ESZB-k+uAK=Ed=LwsShKOtyHdJS_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jay Vosburgh <jay.vosburgh@canonical.com>,
	netdev <netdev@vger.kernel.org>,
	"discuss@openvswitch.org" <discuss@openvswitch.org>
To: Nicholas Bastin <nick.bastin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog010.obsmtp.com ([74.125.150.60]:52993 "HELO
	na6sys009bog010.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751119AbaLHRdl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 12:33:41 -0500
Received: by mail-qa0-f44.google.com with SMTP id i13so3611826qae.17
        for <netdev@vger.kernel.org>; Mon, 08 Dec 2014 09:33:40 -0800 (PST)
In-Reply-To: <CADmMkWdGhw3Rn3gMEtAV8ESZB-k+uAK=Ed=LwsShKOtyHdJS_g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 6, 2014 at 2:47 PM, Nicholas Bastin <nick.bastin@gmail.com> wrote:
> On Fri, Dec 5, 2014 at 4:51 PM, Jesse Gross <jesse@nicira.com> wrote:
>>
>> I don't think there is anything inherently wrong with aggregating TCP
>> segments in VXLAN that are not destined for the local host. This is
>> conceptually the same as doing aggregation for TCP packets where we
>> only perform L2 bridging - in theory we shouldn't look at the upper
>> layers but it is fine as long as we faithfully reconstruct it on the
>> way out.
>
>
> But you don't faithfully reconstruct what the user originally sent - in-path
> reassembly is always wrong, which is why hardware switches don't do it (by
> default, anyhow).  If you configure a middlebox to do some kind of
> assembly/translation/whatever work for you, that's fine, but something that
> advertises itself as a "switch" or "router" should definitely not do this by
> default.
>
> If you reassemble frames you completely obviate any kind of PMTU-D or
> configured MTU that your user is using, and this breaks a lot of paths.  We
> completely disable all GRO/TSO/etc., but if you are able to determine that a
> packet is not destined for the local host you should definitely not mutate
> it.

If you look at the implementation of GRO/TSO, I think you will see
that it does in fact faithfully reconstruct the original message and
path MTU discovery is preserved. On Linux systems, GRO is enabled by
default for all workloads - including those that do not result in
local termination such as bridging.
