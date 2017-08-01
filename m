From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net] ipv6: set fc_protocol with 0 when rtm_protocol is
 RTPROT_REDIRECT
Date: Mon, 31 Jul 2017 20:01:32 -0600
Message-ID: <b0edcf05-9ce4-94d4-3662-767e6ff86843@gmail.com>
References: <e9342d18b97fc227cacc19db1b43f4c7350eed3f.1501419097.git.lucien.xin@gmail.com>
 <9fcbffcb-4a14-764c-7fe4-2108b8944c17@gmail.com>
 <CADvbK_ew8tD=sQQkZ03ijGafFQEzR0sf69DZ1_rNkX9E5mFpuw@mail.gmail.com>
 <11af493f-1128-cae6-d1a3-0d3d962da269@gmail.com>
 <CADvbK_dWwZU1EXf4ehAyV9cWOK-7b4hn=mGrytGTYACrCUUQ6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: network dev <netdev@vger.kernel.org>, davem <davem@davemloft.net>,
        =?UTF-8?Q?Mantas_Mikul=c4=97nas?= <grawity@gmail.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:36877 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751806AbdHACBe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 22:01:34 -0400
Received: by mail-pg0-f52.google.com with SMTP id y129so1559892pgy.4
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 19:01:34 -0700 (PDT)
In-Reply-To: <CADvbK_dWwZU1EXf4ehAyV9cWOK-7b4hn=mGrytGTYACrCUUQ6g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/31/17 7:40 PM, Xin Long wrote:
> To respect the old code more, setting RTPROT_RA only when
> it's with the flag (ADDRCONF | DEFAULT | ROUTEINFO),
> shouldn't it be:

Look at rtm_fill_info:

	if (rt->rt6i_flags & (RTF_DEFAULT | RTF_ROUTEINFO))
                        rtm->rtm_protocol = RTPROT_RA;


If either flag is set the protocol should be RTPROT_RA and looking at
both places that seems correct to me.
