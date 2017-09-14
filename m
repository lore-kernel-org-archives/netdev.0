From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: feature request for kernel module 8021q
Date: Thu, 14 Sep 2017 15:16:32 -0700
Message-ID: <A4D84B7F-5D4A-44C8-875C-C113D7C5C688@gmail.com>
References: <c010d65d-3050-8d88-22aa-cac092dd3904@abeille.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
To: Pierre Colombier <pierre@abeille.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:56430 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751672AbdINWQi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2017 18:16:38 -0400
Received: by mail-pf0-f182.google.com with SMTP id g65so385901pfe.13
        for <netdev@vger.kernel.org>; Thu, 14 Sep 2017 15:16:38 -0700 (PDT)
In-Reply-To: <c010d65d-3050-8d88-22aa-cac092dd3904@abeille.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On September 14, 2017 12:14:04 PM PDT, Pierre Colombier <pierre@abeille=2Ec=
om> wrote:
>Hello
>
>
>One big problem with vlans on linux is that the native interface always
>
>get all vlans=2E
>
>This can cause problem with bridges=2E

What specific problem are you thinking about?

>
>
>One interesting feature would be to have a special vlan number
>
>(let's say 0 or -1 or 4097 ) designed so that it gets all the untagged=20
>trafic and only the untagged trafic=2E

4097 is not a valid number nor is -1 since that closely follows what the V=
LAN ID extracted from the tag would be=2E VLAN 0 is more or less the untagg=
ed VLAN=2E

>
>what do you think about this ?

Provided the HW supports it, with two netdevice operations: ndo_rx_vlan_ad=
d_vid and ndo_rx_vlan_kill_vid you can have your HW filter out the VLAN tag=
s it wishes to receive, respectively not receive anymore=2E If your device =
does not support that, then yes if you send frames with a VLAN tag for whic=
h you are not interested in processing, you are still receiving it unless t=
here is a switch or any kind of VLAN filtering device in between=2E

Bridge has also gained a VLAN filtering that can also be used to only the =
reception/transmission of desired VLAN tags=2E And it also allows you to de=
fine the default VLAN tag (VID1)=20

--=20
Florian
