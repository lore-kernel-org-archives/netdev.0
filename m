From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next v3 6/6] openvswitch: Add vxlan tunneling support.
Date: Thu, 25 Jul 2013 11:19:47 -0700
Message-ID: <CAEP_g=9K=a0BQPBugkExS_ZGySezohOBi9BUDW8c6dna698fMA@mail.gmail.com>
References: <1374688857-14427-1-git-send-email-pshelar@nicira.com> <ksqhg8$jej$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog131.obsmtp.com ([74.125.149.247]:51112 "HELO
	na3sys009aog131.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756108Ab3GYSUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 14:20:08 -0400
Received: by mail-ob0-f172.google.com with SMTP id f8so2308508obp.3
        for <netdev@vger.kernel.org>; Thu, 25 Jul 2013 11:20:07 -0700 (PDT)
In-Reply-To: <ksqhg8$jej$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 24, 2013 at 11:44 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Wed, 24 Jul 2013 at 18:00 GMT, Pravin B Shelar <pshelar@nicira.com> wrote:
>> +
>> +config OPENVSWITCH_VXLAN
>> +     bool "Open vSwitch VXLAN tunneling support"
>> +     depends on INET
>> +     depends on OPENVSWITCH
>> +     depends on VXLAN && !(OPENVSWITCH=y && VXLAN=m)
>
> This seems ugly, is it possible to make these vxlan code be a library as
> iptunnel code?

The goal of separating things out this way is to provide nice layering
between the protocol code and the consumers. There needs to be some
interface between OVS and the tunnel code that straddles the boundary
and putting it in OVS makes the most sense from a hierarchy
perspective.
