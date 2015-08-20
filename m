From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH] bridge: Enable configuration of ageing interval for
 bridges and switch devices.
Date: Wed, 19 Aug 2015 22:38:31 -0700
Message-ID: <CAE4R7bC4aJuk6rFThp-EAmKLkm8QRKXS2EtFF0uauCDUV5WufA@mail.gmail.com>
References: <77EF4405DD4BB54AACCE7DB593DF6A9A9E1E8D@SJEXCHMB14.corp.ad.broadcom.com>
 <alpine.DEB.2.02.1508172358470.13562@rocker1.rocker.net> <77EF4405DD4BB54AACCE7DB593DF6A9A9E2BFE@SJEXCHMB14.corp.ad.broadcom.com>
 <CAE4R7bD-r1=xo2+HMKdPpf7A3Vd7SXYsxm=xC0oNANtuG+F4iw@mail.gmail.com>
 <77EF4405DD4BB54AACCE7DB593DF6A9A9E303A@SJEXCHMB14.corp.ad.broadcom.com>
 <CAE4R7bAFsi0AL2EyTLQRgKLEBO_G4QYXd554uo+tx8OoWnkDuw@mail.gmail.com> <77EF4405DD4BB54AACCE7DB593DF6A9A9E308A@SJEXCHMB14.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Premkumar Jonnala <pjonnala@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:35401 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291AbbHTFiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 01:38:52 -0400
Received: by obbwr7 with SMTP id wr7so23594215obb.2
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 22:38:51 -0700 (PDT)
In-Reply-To: <77EF4405DD4BB54AACCE7DB593DF6A9A9E308A@SJEXCHMB14.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 19, 2015 at 10:12 PM, Premkumar Jonnala
<pjonnala@broadcom.com> wrote:
>
>
>> -----Original Message-----
>> From: Scott Feldman [mailto:sfeldma@gmail.com]
>> Sent: Thursday, August 20, 2015 10:31 AM
>> To: Premkumar Jonnala
>> Cc: netdev@vger.kernel.org
>> Subject: Re: [PATCH] bridge: Enable configuration of ageing interval for bridges
>> and switch devices.
>>
>> On Wed, Aug 19, 2015 at 9:56 PM, Premkumar Jonnala
>> <pjonnala@broadcom.com> wrote:
>> > Thank you Scott.  Please see inline.
>> >
>> >> >> -----Original Message-----
>> >> >> From: Scott Feldman [mailto:sfeldma@gmail.com]
>> >> >> Sent: Tuesday, August 18, 2015 12:48 PM
>> >> >> To: Premkumar Jonnala
>> >> >> Cc: netdev@vger.kernel.org
>> >> >> Subject: Re: [PATCH] bridge: Enable configuration of ageing interval for
>> >> bridges
>> >> >> and switch devices.
>> >> >>
>> >> >>
>> >> >>
>> >> >> On Fri, 14 Aug 2015, Premkumar Jonnala wrote:
>> >> >>
>> >> >> > Bridge devices have ageing interval used to age out MAC addresses
>> >> >> > from FDB.  This ageing interval was not configuratble.
>> >> >> >
>> >> >> > Enable netlink based configuration of ageing interval for bridges and
>> >> >> > switch devices.  The ageing interval changes the timer used to purge
>> >> >> > inactive FDB entries in bridges.  The ageing interval config is
>> >> >> > propagated to switch devices, so that platform or hardware based
>> >> >> > ageing works according to configuration.
>> >> >> >
>> >> >> > Signed-off-by: Premkumar Jonnala <pjonnala@broadcom.com>
>> >> >>
>> >> >> Hi Premkumar,
>> >> >>
>> >> >> I agree with Roopa that we should use existing IFLA_BR_AGEING_TIME.
>> >> >
>> >> > What is the motivation for using 'ip link' command to configure bridge
>> >> attributes?  IMHO,
>> >> > bridge command is better suited for that.
>> >>
>> >> Can you extend bridge command to allow setting/getting these bridge
>> >> attrs?  Looks like you construct a RTM_NEWLINK IFLA_INFO_DATA msg.  No
>> >> changes needed to the kernel.
>> >>
>> >> bridge link set dev br0 ageing_time 1000
>> >>
>> >>  --or--
>> >>
>> >> ip link set dev br0 type bridge ageing_time 1000
>> >
>> > I'd prefer to deprecate/remove all the 6 options on the 'ip link' command and
>> move them to 'bridge' command.
>>
>> We're probably stuck with the 'ip link' commands, since they're
>> already release in the wild and folks may have dependency on them.
>> However, when looking at iproute2 code, look for opportunity to use
>> same code for both paths.
>
> Ok.  Then we can have both ip and bridge commands supporting these options, and freeze the 'ip link' command as it
> exists today.  Any new options in future should be added to the bridge command.  Does that sound okay?

It would be ideal if both command paths use same code so new options
work with either command.  There are other examples where shared code
approach could be used to create synonymous commands:

ip link add name br0 type bridge       --or-- bridge add dev br0
ip link del br0                                  --or-- bridge del dev br0
ip link set dev sw1p1 master br0       --or-- bridge link add dev sw1p1 br0
ip link set dev sw1p1 nomaster br0    --or-- bridge link del sw1p1

There is some precedence of synonymous bridge commands:

ip link set dev sw1p1 type bridge_slave flood on
--or--
bridge link set dev sw1p1 flood on

But I don't know if the same code path is used for both of these.  (It should).

-scott
