From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH 00/29] net: VRF support
Date: Fri, 06 Feb 2015 16:10:34 +0100
Message-ID: <54D4D96A.9030500@6wind.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ebiederm@xmission.com, Roopa Prabhu <roopa@cumulusnetworks.com>
To: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:55469 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755440AbbBFPKh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 10:10:37 -0500
Received: by mail-wi0-f178.google.com with SMTP id bs8so3107424wib.5
        for <netdev@vger.kernel.org>; Fri, 06 Feb 2015 07:10:36 -0800 (PST)
In-Reply-To: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/02/2015 02:34, David Ahern a =C3=A9crit :
[snip]
>
> Design
> ------
> Namespaces provide excellent separation of the networking stack from =
the
> netdevices and up. The intent of VRFs is to provide an additional,
> logical separation at the L3 layer within a namespace.
>
>     +----------------------------------------------------------+
>     | Namespace foo                                            |
>     |                         +---------------+                |
>     |          +------+       | L3/L4 service |                |
>     |          | lldp |       |   (VRF any)   |                |
>     |          +------+       +---------------+                |
>     |                                                          |
>     |                             +-------------------------+  |
>     |                             | VRF M                   |  |
>     |  +---------------------+  +-------------------------+ |  |
>     |  | VRF 1 (default)     |  | VRF N                   | |  |
>     |  |  +---------------+  |  |    +---------------+    | |  |
>     |  |  | L3/L4 service |  |  |    | L3/L4 service |    | |  |
>     |  |  | (VRF unaware) |  |  |    | (VRF unaware) |    | |  |
>     |  |  +---------------+  |  |    +---------------+    | |  |
>     |  |                     |  |                         | |  |
>     |  |+-----+ +----------+ |  |  +-----+ +----------+   | |  |
>     |  || FIB | | neighbor | |  |  | FIB | | neighbor |   | |  |
>     |  |+-----+ +----------+ |  |  +-----+ +----------+   | |  |
>     |  |                     |  |                         |-+  |
>     |  | {dev 1}  {dev 2}    |  | {dev 3} {dev 4} {dev 5} |    |
>     |  +---------------------+  +-------------------------+    |
>     +----------------------------------------------------------+
>
Another question: how is the loopback managed?
If I understand well, there is only one loopback for all vrf.
If I add an address on this loopback, is this address visible from all =
VRF?
Can an app in VRF1 talks to an app in VRF2 via the loopback?
