From: Arend van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v2] brcmfmac: Fix glom_skb leak in brcmf_sdiod_recv_chain
Date: Sun, 11 Jun 2017 10:08:47 +0200
Message-ID: <c4eeec0f-720d-76de-b6d9-68c882450f6f@broadcom.com>
References: <CA+8PC_e8HdkBw4DfGUPO0BbM-W5wftK=i6_vjwFTmS7=axyFUw@mail.gmail.com>
 <1496442569-11307-1-git-send-email-housel@acm.org>
 <CAHp75VcfK5V42vzsh=L+CnX2ZnF=8UORbOf+f2WfmcNH1DbAsw@mail.gmail.com>
 <801f5209-f5a0-7414-f8f4-1500178a680b@broadcom.com>
 <705684CB-D155-45DC-8146-157A536F9FBA@acm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Andy Shevchenko <andy.shevchenko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Franky Lin <franky.lin-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Hante Meuleman <hante.meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Pieter-Paul Giesberts <pieter-paul.giesberts-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Christian Daudt <csd-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>,
        Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
        "open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
        <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
        <brcm80211-dev-list.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        "open list:NETWORKING DRIVERS" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Peter Housel <housel-HInyCGIudOg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <705684CB-D155-45DC-8146-157A536F9FBA-HInyCGIudOg@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11-06-17 02:18, Peter Housel wrote:
> 
>> On Jun 10, 2017, at 12:27 PM, Arend van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org> wrote:
>>
>> On 03-06-17 17:36, Andy Shevchenko wrote:
>>> On Sat, Jun 3, 2017 at 1:29 AM, Peter S. Housel <housel-HInyCGIudOg@public.gmane.org> wrote:
>>>> An earlier change to this function (3bdae810721b) fixed a leak in the
>>>> case of an unsuccessful call to brcmf_sdiod_buffrw(). However, the
>>>> glom_skb buffer, used for emulating a scattering read, is never used
>>>> or referenced after its contents are copied into the destination
>>>> buffers, and therefore always needs to be freed by the end of the
>>>> function.
>>
>> [snip]
>>
>>>> +                       skb_queue_walk(pktq, skb) {
>>>> +                               memcpy(skb->data, glom_skb->data, skb->len);
>>>> +                               skb_pull(glom_skb, skb->len);
>>>> +                       }
>>>>                }
>>>
>>>> +               brcmu_pkt_buf_free_skb(glom_skb);
>>>
>>> Can we just add this one line instead or I'm missing something?
>>
>> I guess. We don't want to walk the packet queue if glom_skb is not
>> carrying data due to brcmf_sdiod_buffrw() failure.
>>
>> So I would go with the patch below as brcmu_pkt_buf_free_skb() simply
>> ignores null pointer.
> 
> I’m fine with this, or indeed most of the other proposed solutions. The important thing is that the leak is fixed; in the driver's current state I was able to run our wearable device out of memory in just over 20 seconds running iperf.

Sure. The reason behind the suggestion from Franky was to get rid of the
label inside branch and I agree with that. To address Andy's comment I
think my proposal should tackle that.

Just out of curiosity, we added the broken-sg-support thing for OMAP
platform. So what platform/mmc-host are you using. I try to keep an
overview where this workaround is needed.

Regards,
Arend
