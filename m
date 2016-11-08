From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next] net: ethtool: add support for forward error
 correction modes
Date: Tue, 8 Nov 2016 13:33:47 -0800
Message-ID: <CAKWE-XqT8kBckOB_CgPsjMo5WkYfPdvZPeWY1XZwiqiAnBVcZQ@mail.gmail.com>
References: <1477363849-36517-1-git-send-email-vidya@cumulusnetworks.com> <25b7fce6-49f9-bd54-5c12-c72298d107c1@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        "John W. Linville" <linville@tuxdriver.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Gal Pressman <galp@mellanox.com>,
        netdev <netdev@vger.kernel.org>,
        Oded Wertheim <odedw@mellanox.com>,
        Ariel Almog <ariela@mellanox.com>,
        Yuval Mintz <Yuval.Mintz@qlogic.com>,
        Tzahi Oved <tzahio@mellanox.com>,
        Roee Shapiro <roees@mellanox.com>,
        Aviad Raveh <aviadr@mellanox.com>,
        Dustin Byford <dustin@cumulusnetworks.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
To: Gal Pressman <galp.dev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f177.google.com ([209.85.213.177]:34239 "EHLO
        mail-yb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752084AbcKHVeY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 16:34:24 -0500
Received: by mail-yb0-f177.google.com with SMTP id d59so35513612ybi.1
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2016 13:33:48 -0800 (PST)
In-Reply-To: <25b7fce6-49f9-bd54-5c12-c72298d107c1@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 3, 2016 at 6:24 AM, Gal Pressman <galp.dev@gmail.com> wrote:
>
>
> On 25/10/2016 05:50, Vidya Sagar Ravipati wrote:
>> SET FEC option:
>> root@tor: ethtool --set-fec  swp1 encoding [off | RS | BaseR | auto] autoneg [off | on]
>>
>> Encoding: Types of encoding
>> Off    :  Turning off any encoding
>> RS     :  enforcing RS-FEC encoding on supported speeds
>> BaseR  :  enforcing Base R encoding on supported speeds
>> Auto   :  Default FEC settings  for  divers , and would represent
>
> divers? :)
Drivers :)
>
>>           asking the hardware to essentially go into a best effort mode.
>>
>> Here are a few examples of what we would expect if encoding=auto:
>> - if autoneg is on, we are  expecting FEC to be negotiated as on or off
>>   as long as protocol supports it
>> - if the hardware is capable of detecting the FEC encoding on it's
>>       receiver it will reconfigure its encoder to match
>> - in absence of the above, the configuration would be set to IEEE
>>   defaults.
>
> Not sure I follow, why do we need an autoneg option if encoding type can be set to auto?
Auto is one of the FEC configuration modes  which indicates  the
drivers to set the IEEE defaults based on speed/duplex combination of
the port. i.e. RS FEC mode will be set in case of 100G/full

Auto negotiation is the configuration for the link  to negotiate the
FEC capabilities and different FEC modes with other endpoint  using
encoded bits D44:47 in base link code word.
