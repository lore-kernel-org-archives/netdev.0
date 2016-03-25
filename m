From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: =?UTF-8?Q?Re=3A_veth_regression_with_=22don=E2=80=99t_modify_ip=5Fsummed=3B_?=
	=?UTF-8?Q?doing_so_treats_packets_with_bad_checksums_as_good=2E=22?=
Date: Fri, 25 Mar 2016 15:23:12 -0700
Message-ID: <CAM_iQpUEdfeKNQzu2v74YR8Srezw11aYiTqQ0w_foaoBr4mQug@mail.gmail.com>
References: <56F463D6.7080406@candelatech.com>
	<CAM_iQpWv_iP1ZtsRQT0YsztMrf6rdaXN2V57PUu5oBe5kR56AQ@mail.gmail.com>
	<56F4810A.9060904@candelatech.com>
	<56F49036.8050902@candelatech.com>
	<56F490B2.3090603@candelatech.com>
	<CAKUBDd9TjFTvXSEL=+J02PVndNG-gcrMOpRo_MFp4J-oOnLrvQ@mail.gmail.com>
	<56F4BFF1.8010806@candelatech.com>
	<CAM_iQpUaBD-HmHVAcEBCRw38PbecjYk2to+DO9TNkLY93u2_NA@mail.gmail.com>
	<56F4C8FD.7030907@candelatech.com>
	<CAM_iQpWwch3+6u+X0DBGyVSWttd7Nz2COdmq2q=G9BxisW52bA@mail.gmail.com>
	<56F5A618.9070206@candelatech.com>
	<CAKUBDd844=BTpK2B2izzRGqwKQV5RtsFAO9nFQ5CJqDENLFW5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ben Greear <greearb@candelatech.com>,
	netdev <netdev@vger.kernel.org>, Evan Jones <ej@evanjones.ca>,
	Cong Wang <cwang@twopensource.com>
To: Vijay Pandurangan <vijayp@vijayp.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:35752 "EHLO
	mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754467AbcCYWXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 18:23:14 -0400
Received: by mail-qk0-f175.google.com with SMTP id o6so42543123qkc.2
        for <netdev@vger.kernel.org>; Fri, 25 Mar 2016 15:23:13 -0700 (PDT)
In-Reply-To: <CAKUBDd844=BTpK2B2izzRGqwKQV5RtsFAO9nFQ5CJqDENLFW5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 25, 2016 at 2:59 PM, Vijay Pandurangan <vijayp@vijayp.ca> wrote:
> consider two scenarios, where process a sends raw ethernet frames
> containing UDP packets to b
>
> I) process a --> veth --> process b
>
> II) process a -> eth -> wire -> eth -> process b
>
> I believe (I) is the simplest setup we can create that will replicate this bug.
>
> If process a sends frames that contain UDP packets to process b, what
> is the behaviour we want if the UDP packet *has an incorrect
> checksum*?
>
> It seems to me that I and II should have identical behaviour, and I
> would think that (II) would not deliver the packets to the
> application.
>
> In (I) with Cong's patch would we be delivering corrupt UDP packets to
> process b despite an incorrect checksum in (I)?
>

Right, I thought packet socket does the checksum by itself, so the
problem is: if user-space does the checksum like packet socket, its
checksum could be wrong therefore we can not trust it on RX path
once it loops back.

Let me think about it again.
