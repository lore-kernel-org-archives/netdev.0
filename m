From: Ani Sinha <ani@aristanetworks.com>
Subject: Re: [PATCH net 1/2] net: dev_queue_xmit_nit: fix skb->vlan_tci field value
Date: Tue, 8 Jan 2013 22:06:45 -0800
Message-ID: <CAOxq_8MXCvGpq4Q0UfxSbWMDNTusrK710fQ11qgfXKWS+zpoZQ@mail.gmail.com>
References: <CAOUgPvRGQ4XQ-HCFzwKi5rFFfC1fJcicH8DxH0pUjAvgxfi7cw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, dborkman <dborkman@redhat.com>,
	edumazet <edumazet@google.com>, Jiri Pirko <jpirko@redhat.com>
To: Paul Pearce <pearce@cs.berkeley.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:43855 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752047Ab3AIGGr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 01:06:47 -0500
Received: by mail-ie0-f172.google.com with SMTP id c13so1609561ieb.3
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2013 22:06:47 -0800 (PST)
In-Reply-To: <CAOUgPvRGQ4XQ-HCFzwKi5rFFfC1fJcicH8DxH0pUjAvgxfi7cw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 8, 2013 at 9:15 PM, Paul Pearce <pearce@cs.berkeley.edu> wrote:
> On Tue, 2013-01-08 at 19:51 +0100, Daniel Borkmann wrote:
>> VLAN packets that are locally injected through taps will loose their
>> skb->vlan_tci value when they pass dev_hard_start_xmit and get looped
>> back to a packet sniffer via dev_queue_xmit_nit. Besides others, this
>> meta data is used in Linux socket filtering for VLANs. Tested with a
>> VLAN ancillary ops filter.
>>
>> Patch is based on a previous version by Jiri Pirko.
>
> I think there may be issues with the patch beyond Eric's comments. It
> seems to trash packet contents.
>
> I applied this patch to Fedora flavored kernel 3.6.11-1.fc16.x86_64.
> vlan tagged packets injected via libpcap's pcap_inject() came out
> mangled at the packet filters.
>

The proposed patch tries to fix the issue that arose after the
following commit :

commit b40863c667c16b7a73d4f034a8eab67029b5b15a
Author: Eric Dumazet <edumazet@google.com>
Date:   Tue Sep 18 20:44:49 2012 +0000

    net: more accurate network taps in transmit path


I do not believe 3.6.11 kernel has this change. 3.6.11 should not need
the patch.

ani
