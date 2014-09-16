From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2 net-next 0/7] net: foo-over-udp (fou)
Date: Mon, 15 Sep 2014 17:15:07 -0700
Message-ID: <CAEP_g=9Rawi_PPW1d=_7xCjWK-QT7_Ph7JOG0XP7UhWyvo58Vw@mail.gmail.com>
References: <1410750483-3236-1-git-send-email-therbert@google.com>
 <CAJ3xEMjC5PQENzCXS9SNVm6zUVn7pydxf1MLQ57Br1sGjD1ngQ@mail.gmail.com>
 <CA+mtBx_+JxUn4zT+XN8DpQcCoz5Du+QtF1xzLno2m1yCwbr6ow@mail.gmail.com>
 <CAEP_g=_bnr94YHKd40qipmniYs80CH4g3iFiHOgZHOnDQ82Epw@mail.gmail.com> <CA+mtBx8ATqggG5n-_gUr=QjOp3KeUzD4=+wNgyJBx1C24AsuUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog134.obsmtp.com ([74.125.149.83]:48987 "HELO
	na3sys009aog134.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1760625AbaIPAPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 20:15:33 -0400
Received: by mail-qc0-f176.google.com with SMTP id x13so2814901qcv.35
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 17:15:27 -0700 (PDT)
In-Reply-To: <CA+mtBx8ATqggG5n-_gUr=QjOp3KeUzD4=+wNgyJBx1C24AsuUw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2014 at 3:59 PM, Tom Herbert <therbert@google.com> wrote:
> On Mon, Sep 15, 2014 at 3:44 PM, Jesse Gross <jesse@nicira.com> wrote:
>> On Mon, Sep 15, 2014 at 12:15 PM, Tom Herbert <therbert@google.com> wrote:
>>> On Mon, Sep 15, 2014 at 11:08 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>>> On Mon, Sep 15, 2014 at 6:07 AM, Tom Herbert <therbert@google.com> wrote:
>>>> [...]
>>>>> * Notes
>>>>>   - This patch set does not implement GSO for FOU. The UDP encapsulation
>>>>>     code assumes TEB, so that will need to be reimplemented.
>>>>
>>>> Can you please clarify this point little further? Specifically, today
>>>> few NICs are
>>>> advertizing NETIF_F_GSO_UDP_TUNNEL when they are practically GSO
>>>> capable only w.r.t to VXLAN. What happens when such NIC expose this
>>>> cap and a large guest frame goes through GRE over UDP or alike tunneling?
>>>>
>>> My interpretation is that NETIF_F_GSO_UDP_TUNNEL means L3/L4
>>> encapsulation over UDP, not VXLAN. If the NIC implements things
>>> properly following the generic interface then I believe it should work
>>> with various flavors of UDP encapsulation (FOU, GUE, VXLAN, VXLAN-gpe,
>>> geneve, LISP, L2TP, nvgre, or whatever else people might dream up).
>>> This presumes that any encapsulation headers doesn't require any per
>>> segment update (so no GRE csum for instance). The stack will set up
>>> inner headers as needed, which should enough to provide to devices the
>>> offsets inner IP and TCP header which are needed for the the TSO
>>> operation (outer IP and UDP can be deduced also).
>>
>> From the NICs that I am familiar with this is mostly true. The main
>> part that is missing from the current implementation is a length
>> limit: just because the hardware can skip over headers to an offset
>> doesn't mean that it can do so to an arbitrary depth. For example, in
>> the NICs that are exposing VXLAN as NETIF_F_GSO_UDP_TUNNEL we can
>> probably assume that this is limited to 8 bytes. With the Intel NICs
>> that were just announced with Geneve support, this limit has been
>> increased to 64. If we add a parameter to the driver interface to
>> expose this then it should be generic across tunnels.
>
> Sounds reasonable, although I think you'll need to define precisely
> what length refers to.

I agree, the definition is important.
