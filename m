From: Tim Harvey <tharvey@gateworks.com>
Subject: Re: IMX6 FEC connection drops occasionally with 'MDIO read timeout'
Date: Wed, 12 Apr 2017 09:15:11 -0700
Message-ID: <CAJ+vNU2itJEBMLNz--w9FOis_jMHW9c+UPwU6wh+ma59kbeswA@mail.gmail.com>
References: <CAJ+vNU1UG2EeJSTStT_BJ+RiRe4a8YwfRgnE6DsRghTLetq_rg@mail.gmail.com>
 <20170407160915.GF23415@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        Lucas Stach <l.stach@pengutronix.de>,
        Fugang Duan <fugang.duan@nxp.com>,
        Koen Vandeputte <koen.vandeputte@ncentric.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f181.google.com ([209.85.128.181]:36157 "EHLO
        mail-wr0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753860AbdDLQPN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 12:15:13 -0400
Received: by mail-wr0-f181.google.com with SMTP id c55so20673125wrc.3
        for <netdev@vger.kernel.org>; Wed, 12 Apr 2017 09:15:13 -0700 (PDT)
In-Reply-To: <20170407160915.GF23415@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 7, 2017 at 9:09 AM, Andrew Lunn <andrew@lunn.ch> wrote:
> On Fri, Apr 07, 2017 at 07:47:17AM -0700, Tim Harvey wrote:
>> Greetings,
>>
>> I've had a couple of users report that they are getting occasional
>> link drops when using IMX6 FEC on our boards which are using a Marvell
>> 88E1510 PHY:
>>
>> [ 9348.474418] fec 2188000.ethernet eth0: MDIO read timeout
>> [ 9350.478804] fec 2188000.ethernet eth0: Link is Down
>>
>> If they bring the interface back up it works fine.
>>
>> The most recent version of Linux they have tested and seen this on is
>> v4.9 with CONFIG_MARVELL_PHY=y
>>
>> Has anyone else run into this or know what the issue could be? Should
>> there be any retries at the MDIO level or above?
>
> Hi Tim
>
> MDIO is assumed to be reliable. It failing is bad.
>
> However, ETIMEOUT is interesting. The MDIO protocol has no flow
> control. There is no way for the PHY to delay replying.
>
> I would suggest you look at the power management code. What i have
> seen with the FEC, when using switches attached to the FEC, is that if
> the clocks are turned off, you get ETIMEOUT from MDIO.
>
>     Andrew

Andrew,

Thanks for the reply. Your talking about suspend/resume power
management right? The users reporting this were not using
suspend/resume.

With regards to clock are you talking about the IPG clock? Is there
any other way that would get turned off other than fec suspend/resume?

Tim
