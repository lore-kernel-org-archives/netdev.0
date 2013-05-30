From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: GREv4 ipv6 is broken for UDP stream on 3.9
Date: Thu, 30 May 2013 09:46:15 -0700
Message-ID: <CALnjE+pHEqdZ9KADF9L+8WfGwi+q-NgXSR7bnEiz4BhArY7q-w@mail.gmail.com>
References: <CAM8tLiOQq2a_Z=F_V5A2saPN+JfwN7Ey29r+UmUK_f9oYF5vCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dmitry Kravkov <dkravkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog104.obsmtp.com ([74.125.149.73]:44682 "HELO
	na3sys009aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S965036Ab3E3QqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 12:46:16 -0400
Received: by mail-qc0-f179.google.com with SMTP id e1so242458qcx.24
        for <netdev@vger.kernel.org>; Thu, 30 May 2013 09:46:15 -0700 (PDT)
In-Reply-To: <CAM8tLiOQq2a_Z=F_V5A2saPN+JfwN7Ey29r+UmUK_f9oYF5vCw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I sent out fix "udp6: Fix udp fragmentation for tunnel traffic."
Can you give it a try ?

Thanks.

On Wed, May 29, 2013 at 1:16 AM, Dmitry Kravkov <dkravkov@gmail.com> wrote:
> Hi,
>
> since 3.9-rc1 i see that rx side drops all data packets for:
>
> netperf -6 -t UDP_STREAM -H fe80::5efe:c0a8:630c%gre_7 -l 1
>
> when gre_7 is:
>
> 13: gre_7: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1476 qdisc noqueue state UNKNOWN
>     link/gre 192.168.99.29 peer 192.168.99.12
>
> The packets just gets corrupted.
>
> This bisected to:
> commit 68c331631143f5f039baac99a650e0b9e1ea02b6
> Author: Pravin B Shelar <pshelar@nicira.com>
> Date:   Thu Feb 14 14:02:41 2013 +0000
>
>     v4 GRE: Add TCP segmentation offload for GRE
>
> Looks like gre_gso_segment build wrong segments for GSO flow.
