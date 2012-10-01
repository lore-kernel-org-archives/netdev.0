From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 3/3] ipv4: gre: add GRO capability
Date: Mon, 1 Oct 2012 13:56:14 -0700
Message-ID: <CAEP_g=_nSb-ite51PM-E8SY53yOPiZs8N3gDrYNc0L4OU2Ht=A@mail.gmail.com>
References: <1348750130.5093.1227.camel@edumazet-glaptop> <CAEP_g=-JAYHXM86AYNp7BhDV+eqfkKVgC+SJS1MVdo0K8fRLSQ@mail.gmail.com>
 <1348769294.5093.1566.camel@edumazet-glaptop> <1348769990.5093.1584.camel@edumazet-glaptop>
 <CAEP_g=8B7xZPxye0Kuu-EVKpTDt1a3nsJKb61aaYaqOGsYGx8w@mail.gmail.com> <1348841041.5093.2477.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog128.obsmtp.com ([74.125.149.141]:60709 "HELO
	na3sys009aog128.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756434Ab2JAU4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 16:56:35 -0400
Received: by mail-oa0-f46.google.com with SMTP id h16so5553878oag.19
        for <netdev@vger.kernel.org>; Mon, 01 Oct 2012 13:56:34 -0700 (PDT)
In-Reply-To: <1348841041.5093.2477.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 28, 2012 at 7:04 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2012-09-27 at 15:03 -0700, Jesse Gross wrote:
>
>> We wouldn't actually do the decapsulation at the point of GRO.  This
>> is actually pretty similar to what we do with TCP - we merge TCP
>> payloads even though we haven't done any real IP processing yet.
>> However, we do check firewall rules later if we actually hit the IP
>> stack.  GRE would work the same way in this case.
>>
>> What I'm describing is pretty much exactly what NICs will be doing, so
>> if that doesn't work we'll have a problem...
>
> GRO ability to truly aggregate data is kind of limited to some
> workloads. How NICs will handle interleaved flows I dont really know.
>
> What you describe needs a serious GRO preliminary work, because it
> depends on napi_gro_flush() being called from time to time, while we
> need something else, more fine grained.
>
> (I am pretty sure GRO needs some love from us, it looks like some
> packets can stay a long time in gro_list. It would be nice if it was
> able to reorder packets (from same flow) as well)

It's definitely possible to improve GRO in a couple of areas.  I'm not
quite sure why you say that these changes are related to tunnels
though, since they're not really different from say, a VLAN tag.

> Anyway, my changes are self-contained in a new file and non intrusive.
>
> As soon as we can provide a better alternative we can revert them ?

Sure, I don't have a problem with your patches for now.  I was just
trying to think about different approaches.
