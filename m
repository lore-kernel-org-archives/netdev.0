From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH v2] fjes: Do not load fjes driver if system does not have extended socket device.
Date: Sun, 12 Mar 2017 19:29:21 +0100
Message-ID: <87mvcqmjr2.fsf@miraculix.mork.no>
References: <7a1a2dbc-99e0-06ba-2261-6e6382937486@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
        izumi.taku@jp.fujitsu.com
To: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:51615 "EHLO canardo.mork.no"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755675AbdCLSar (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 12 Mar 2017 14:30:47 -0400
In-Reply-To: <7a1a2dbc-99e0-06ba-2261-6e6382937486@gmail.com> (Yasuaki
        Ishimatsu's message of "Wed, 8 Mar 2017 16:05:18 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yasuaki Ishimatsu <yasu.isimatu@gmail.com> writes:

> The fjes driver is used only by FUJITSU servers and almost of all
> servers in the world never use it. But currently if ACPI PNP0C02
> is defined in the ACPI table, the following message is always shown:
>
>  "FUJITSU Extended Socket Network Device Driver - version 1.2
>   - Copyright (c) 2015 FUJITSU LIMITED"

Matching on PNP0C02 is fundamentally wrong. It's a way to load a device
driver on all ACPI systems.  You should not do that. I don't think it is
fair to make everyone suffer because of your inability to properly
narrow down the driver matching rules.

Could we please just delete the whole MODULE_DEVICE_TABLE() from this
driver until a proper solution is found? That way we don't need to
blacklist the driver everywhere.


Bj=C3=B8rn
