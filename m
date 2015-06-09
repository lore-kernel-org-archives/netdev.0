From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC net-next 0/3] Proposal for VRF-lite
Date: Tue, 09 Jun 2015 14:30:06 +0200
Message-ID: <5576DC4E.6060206@6wind.com>
References: <cover.1433561681.git.shm@cumulusnetworks.com> <20150609101550.GA10411@pox.localdomain>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hannes@stressinduktion.org, dsahern@gmail.com,
	ebiederm@xmission.com, hadi@mojatatu.com, davem@davemloft.net,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	jtoppins@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: Thomas Graf <tgraf@suug.ch>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:33446 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752586AbbFIMaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 08:30:09 -0400
Received: by wgez8 with SMTP id z8so12088394wge.0
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2015 05:30:08 -0700 (PDT)
In-Reply-To: <20150609101550.GA10411@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 09/06/2015 12:15, Thomas Graf a =E9crit :
> On 06/08/15 at 11:35am, Shrijeet Mukherjee wrote:
> [...]
>> model with some performance paths that need optimization. (Specifica=
lly
>> the output route selector that Roopa, Robert, Thomas and EricB are
>> currently discussing on the MPLS thread)
>
> Thanks for posting these patches just in time. This explains how
> you intent to deploy Roopa's patches in a scalable manner.
>
>> High Level points
>>
>> 1. Simple overlay driver (minimal changes to current stack)
>>     * uses the existing fib tables and fib rules infrastructure
>> 2. Modelled closely after the ipvlan driver
>> 3. Uses current API and infrastructure.
>>     * Applications can use SO_BINDTODEVICE or cmsg device indentifie=
rs
>>       to pick VRF (ping, traceroute just work)
>
> I like the aspect of reusing existing user interfaces. We might
> need to introduce a more fine grained capability than CAP_NET_RAW
> to give containers the privileges to bind to a VRF without
> allowing them to inject raw frames.
>
> Given I understand this correctly: If my intent was to run a
> process in multiple VRFs, then I would need to run that process
> in the host network namespace which contains the VRF devices
> which would also contain the physical devices. While I might want
> to grant my process the ability to bind to VRFs, I may not want
> to give it the privileges to bind to any device. So we could
> consider introducing CAP_NET_VRF which would allow to bind to
> VRF devices.

If I understand correctly, all existing applications should also be mod=
ified
if I want to run them into a VRF/MRF (see my previous email)?

ssh, dhcp, httpd, etc should be runnable per MRF without modifications =
of
their source code. So, it becomes a netns. What's about an IKE dameon?

It makes sense to have both: netns and MRF ; each can have their own lo=
gics
of VRF-like behavior depending on how a VRF is defined by the end users=
=2E
