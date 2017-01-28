From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH RFC net-next] packet: always ensure that we pass
 hard_header_len bytes in skb_headlen() to the driver
Date: Fri, 27 Jan 2017 19:19:02 -0500
Message-ID: <CAF=yD-KqQdPVn-CFAu3ak+c3NRO9gfT+8UwXXS4eSv9ax0iAnA@mail.gmail.com>
References: <20170126213742.GE29475@oracle.com> <CAF=yD-L66dFV64fx21A3059LRiot_-j0Ykp9GkRFwf52099upQ@mail.gmail.com>
 <20170127020836.GH29475@oracle.com> <CAF=yD-LWLDQhQMBA9O5T5k+di5VKMPtix+pHLb-zjUtd4+WZmQ@mail.gmail.com>
 <20170127151119.GB25829@oracle.com> <CAF=yD-+LS6g572Uo5oErq7uazxxPwXXo0w2p4zcHDbXxkuah6Q@mail.gmail.com>
 <20170127170320.GD25829@oracle.com> <CAF=yD-J6r+myVVAb5uNL8-Fua7Gr5q8U+veqPB=xm4gNOTp5Tg@mail.gmail.com>
 <20170127200639.GF25829@oracle.com> <CAF=yD-+GGAdvgXoZeMshyQXXh_3m9kjDGNFf9FQ43rxJgk__vw@mail.gmail.com>
 <20170127215848.GG25829@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Network Development <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36754 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750741AbdA1ATo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 19:19:44 -0500
Received: by mail-wm0-f66.google.com with SMTP id r126so61787960wmr.3
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 16:19:43 -0800 (PST)
In-Reply-To: <20170127215848.GG25829@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 27, 2017 at 4:58 PM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (01/27/17 15:51), Willem de Bruijn wrote:
>     :
>> - limit capable() check to drivers with with .validate callback
> (aka second option below)
>     :
>> - let privileged applications shoot themselves in the foot (change nothing).
>
>> The second will break variable length header protocols unless
>> you exhaustively search for all variable length protocols and add
>> validate callbacks first.
>
> other than ax25, are there variable length header protocols out there
> without ->validate, and which need the CAP_RAW_SYSIO branch?

I don't know. An exhaustive search of protocols (by header_ops) may be
needed to say for sure.

If there are none, then the solution indeed is quite simple.

> I realize that, to an extent, even ethernet is a protocol whose
> header is > 14 with vlan, but from the google search, seems like it
> was mostly ax25 that really triggered a large part of the check.
>
> If we think that there are a large number of these (that dont have a
> ->validate, to fix up things as desired) I'd just go for the "change
> nothing in pf_packet" option.
>
> As I found out many drivers like ixgbe and sunvnet have defensive checks
> in the Tx path anyway, and xen_netfront can also join that group with
> a few simple checks.

Okay. I suspect that there are few, if any. But this is fragile code.
