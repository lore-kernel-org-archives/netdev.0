From: "Waskiewicz Jr, Peter" <peter.waskiewicz.jr@intel.com>
Subject: Re: [PATCH net-next 2/6] bpf: add meta pointer for direct access
Date: Thu, 28 Sep 2017 21:40:40 +0000
Message-ID: <E0D909EE5BB15A4699798539EA149D7F077E66D3@ORSMSX103.amr.corp.intel.com>
References: <458f9c13ab58abb1a15627906d03c33c42b02a7c.1506297988.git.daniel@iogearbox.net>
 <20170925181000.GA60144@C02RW35GFVH8.dhcp.broadcom.net>
 <59C94FF4.8070900@iogearbox.net>
 <20170926172140.GB60144@C02RW35GFVH8.dhcp.broadcom.net>
 <E0D909EE5BB15A4699798539EA149D7F077E53D6@ORSMSX103.amr.corp.intel.com>
 <CAHashqBMfXp-uYH9ANfdaNfez9f4pcrOjnbX2WAFAdBwaJAtvw@mail.gmail.com>
 <E0D909EE5BB15A4699798539EA149D7F077E6438@ORSMSX103.amr.corp.intel.com>
 <bdce98b7-1d32-3cd9-1289-79807af8443f@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>,
        "jakub.kicinski@netronome.com" <jakub.kicinski@netronome.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "mchan@broadcom.com" <mchan@broadcom.com>
To: John Fastabend <john.fastabend@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:4294 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751058AbdI1Vkm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 28 Sep 2017 17:40:42 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/28/17 2:23 PM, John Fastabend wrote:
> [...]
> 
>> I'm pretty sure I misunderstood what you were going after with
>> XDP_REDIRECT reserving the headroom.  Our use case (patches coming in a
>> few weeks) will populate the headroom coming out of the driver to XDP,
>> and then once the XDP program extracts whatever hints it wants via
>> helpers, I fully expect that area in the headroom to get stomped by
>> something else.  If we want to send any of that hint data up farther,
>> we'll already have it extracted via the helpers, and the eBPF program
>> can happily assign it to wherever in the outbound metadata area.
> 
> In case its not obvious with the latest xdp metadata patches the outbound
> metadata can then be pushed into skb fields via a tc_cls program if needed.

Yes, that was what I was alluding to with "can happily assign it to 
wherever."  The patches we're working on are driver->XDP, then anything 
else using the latest meta-data patches would be XDP->anywhere else.  So 
I don't think we're going to step on any toes.

Thanks John,
-PJ
