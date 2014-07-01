From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [net-next v2 02/13] tcp: tcp_v[46]_conn_request: fix snt_synack initialization
Date: Mon, 30 Jun 2014 22:24:57 -0400
Message-ID: <CADVnQymh+Vf97Cbt=rYs=9bi+=+L6vCPW4ypx377HBQUV7pyqQ@mail.gmail.com>
References: <1403705402-14388-1-git-send-email-octavian.purdila@intel.com>
	<1403705402-14388-3-git-send-email-octavian.purdila@intel.com>
	<CADVnQykKYPVt-g8WtE29Xu_0Si-Lx_pMxnix4i2BqFhAV9BD8Q@mail.gmail.com>
	<CAE1zotKXSqy0O+OQq1f+ab7k3hL4ntMwk3CX4pOYUXoVeGjb7A@mail.gmail.com>
	<CADVnQy=Fu-fJDczTLjQPreGq2-++S9sp2akj84Orv5p_b3Qc=g@mail.gmail.com>
	<CAE1zot+Oqqw+8m9Pr4R-W5wSqmYU5f6xqykCSaZP+fnTpLVO-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, Daniel Lee <longinus00@gmail.com>,
	Yuchung Cheng <ycheng@google.com>, Jerry Chu <hkchu@google.com>
To: Octavian Purdila <octavian.purdila@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:60171 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752011AbaGACY6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 22:24:58 -0400
Received: by mail-wg0-f44.google.com with SMTP id x13so8919550wgg.15
        for <netdev@vger.kernel.org>; Mon, 30 Jun 2014 19:24:57 -0700 (PDT)
In-Reply-To: <CAE1zot+Oqqw+8m9Pr4R-W5wSqmYU5f6xqykCSaZP+fnTpLVO-Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 30, 2014 at 5:00 PM, Octavian Purdila
<octavian.purdila@intel.com> wrote:
> On Mon, Jun 30, 2014 at 10:11 PM, Neal Cardwell <ncardwell@google.com> wrote:
>> On Mon, Jun 30, 2014 at 7:50 AM, Octavian Purdila
>> <octavian.purdila@intel.com> wrote:
>>> In that case perhaps it is better to add a new field (or rename the
>>> existing one if it is not needed anymore) to store the syn arrival
>>> time? I think it is confusing to store the syn arrival time in the
>>> "synack sent time" field.
>>
>> That would be reasonable, but I think the longstanding "snt_synack"
>> name is also good, since the primary purpose of that field is to
>> measure the RTT of the SYNACK packet.
>>
>
> So, if we use it to measure the RTT, with this approach, wouldn't the
> RTT estimate be artificially high if sending the syn-ack fails? And
> wouldn't that negatively affect congestion control ?
>
> On second thought, if we need to retransmit the syn-ack then it does
> not matter much. Is this the reason we don't care?

tcp_synack_rtt_meas() already explicitly checks to see if the SYNACK
was retransmitted before using the time to calculate the SYNACK RTT.
So this kind of scenario should be OK.

neal
