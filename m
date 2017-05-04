From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [PATCH net-next 9/9] ipvlan: introduce individual MAC addresses
Date: Thu, 4 May 2017 15:15:44 -0700
Message-ID: <CAF2d9jgom6uFn-FGkMj=0NVTxzdHonN6KuOZESP=YAbCdimhMw@mail.gmail.com>
References: <20170427145142.15830-1-marco.chiappero@intel.com>
 <20170427145142.15830-10-marco.chiappero@intel.com> <1493310033.27948.3.camel@redhat.com>
 <1493310219.27948.5.camel@redhat.com> <695CDAEB5A6CE2498DE413F2A9AA82960915DF0C@IRSMSX101.ger.corp.intel.com>
 <1493741366.32411.7.camel@redhat.com> <695CDAEB5A6CE2498DE413F2A9AA82960915EF08@IRSMSX101.ger.corp.intel.com>
 <20170504184345.3f9afb8e@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Chiappero, Marco" <marco.chiappero@intel.com>,
        Dan Williams <dcbw@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        "Grandhi, Sainath" <sainath.grandhi@intel.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:33168 "EHLO
        mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751459AbdEDWQG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 18:16:06 -0400
Received: by mail-io0-f169.google.com with SMTP id p24so40346649ioi.0
        for <netdev@vger.kernel.org>; Thu, 04 May 2017 15:16:05 -0700 (PDT)
In-Reply-To: <20170504184345.3f9afb8e@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 4, 2017 at 9:43 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Thu, 4 May 2017 09:37:00 +0000, Chiappero, Marco wrote:
>> This looks conceptually wrong. Yes, ipvlan works at L3 (which is an
>> implementation detail anyway), but slaves are Ethernet interfaces and
>> should behave as much as possible as such regardless, with an
>> individual MAC address assigned.
>
> Isn't the proper fix then converting ipvlan interfaces to be L3 only
> interfaces? I.e., ARPHRD_NONE? There's not much ipvlan can do with
> arbitrary Ethernet frames anyway. Of course, a flag to switch to the
> new behavior would be needed in order to preserve backwards
> compatibility.
>
There is mode = L3/L3s for that.

> This patchset looks very wrong. For proper support of multiple MAC
> addresses, we have macvlan and it's pointless to add that to ipvlan.
> And doing some kind of weird MAC NAT in ipvlan just to satisfy broken
> tools that can't cope with multiple interfaces with the same MAC address
> is wrong, too. Those tools are already broken anyway, there's nothing
> preventing anyone to set the same MAC address to multiple interfaces.
> I suppose those tools don't work with bonding and bridge, either?
>
+1

>> So, either we fix this by forcing slaves to stay in sync with master,
>
> Yes, that's the correct behavior. Well, at least as correct as one can
> get with the ipvlan broken design of pretending that an interface is L2
> when in fact, it is not.
>
conceptually view it as a single link (one L2) but mux/demux @ L3 for
multi-ns world with different routing needs without needing additional
packet processing.

>  Jiri
