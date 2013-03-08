From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next 1/4] net: Add skb_headers_offset_update helper function.
Date: Thu, 7 Mar 2013 23:23:02 -0800
Message-ID: <CALnjE+pDX_TRfy3hUykQxEBv=8zO4zic=91rpM3COXTw5dJZeg@mail.gmail.com>
References: <1362698500-2411-1-git-send-email-pshelar@nicira.com>
	<20130307214025.639c713c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, netdev@vger.kernel.org, jesse@nicira.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog134.obsmtp.com ([74.125.149.83]:58171 "HELO
	na3sys009aog134.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753460Ab3CHHXE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 02:23:04 -0500
Received: by mail-qa0-f71.google.com with SMTP id z4so2349010qan.10
        for <netdev@vger.kernel.org>; Thu, 07 Mar 2013 23:23:02 -0800 (PST)
In-Reply-To: <20130307214025.639c713c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 7, 2013 at 9:40 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Thu,  7 Mar 2013 15:21:40 -0800
> Pravin B Shelar <pshelar@nicira.com> wrote:
>
>> +static void skb_headers_offset_update(struct sk_buff *skb, int off)
>> +{
>> +     /* {transport,network,mac}_header and tail are relative to skb->head */
>> +     skb->transport_header += off;
>> +     skb->network_header   += off;
>> +     if (skb_mac_header_was_set(skb))
>> +             skb->mac_header += off;
>> +     skb->inner_transport_header += off;
>> +     skb->inner_network_header += off;
>> +}
>> +
>
> Won't this cause an unused function warning if NET_SKBUFF_DATA_USES_OFFSET is defined?

This function is used in both cases, so it should be ok.

Thanks,
Pravin.
