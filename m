From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: How to configure MDI status per port
Date: Tue, 30 Jun 2009 17:32:25 -0700
Message-ID: <9929d2390906301732s7752b86aj8fa969ce28659906@mail.gmail.com>
References: <4A3085CA.2000300@riverbed.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>,
	Arthur Jones <ajones@riverbed.com>
To: clala@riverbed.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f188.google.com ([209.85.210.188]:33704 "EHLO
	mail-yx0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760600AbZGAAcW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 20:32:22 -0400
Received: by yxe26 with SMTP id 26so764594yxe.33
        for <netdev@vger.kernel.org>; Tue, 30 Jun 2009 17:32:25 -0700 (PDT)
In-Reply-To: <4A3085CA.2000300@riverbed.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 10, 2009 at 9:19 PM, Chaitanya Lala<clala@riverbed.com> wro=
te:
> Hi,
>
> I have a requirement to be able to configure/change the default MDI-X=
 status
> of each ethernet port. This should be possible on a per port basis i.=
e. it
> should be possible to configure, say, port 0 to auto mdi-x mode & por=
t 1 to
> manual MDI-X mode. A couple of possible implementation strategies cou=
ld
> achieve this but both have some problems. Following is an overview of=
 the
> two.
>
> 1.) Use a module parameter. Pass an array of values, each value
> corresponding to ethernet port supported by the driver. For example,
> modprobe e1000e mdix_values=3D1,0,2,0 (where the numbers 0,1 & 2 repr=
esent
> auto MDI-X, manual MDI =C2=A0& manual MDI-X modes respectively) assig=
ns value 1
> for port 0, 0 for port 1, 2 for port 2 and so on. This value can be a=
ssigned
> to the mdix parameter (member of the e1000_phy_info structure in the =
case of
> e1000e driver) in the probe routine. The problem here is how to map t=
he
> ordered list of numbers to the ethernet ports so that each number in =
the
> list always corresponds to the same ethernet interface. I assume that=
 the
> order of enumeration of ethernet ports can change based on changes to=
 the
> system topology, i.e. plugging/pulling of additional NIC cards.
>
> 2.) Using ethtool and each driver sets the value in its set_settings
> function (part of the ethtool operations structure). The value receiv=
ed for
> each port can be assigned to the mdix parameter (member of the
> e1000_phy_info structure in the case of e1000e driver) but the proble=
m is
> that the value is useful iff it is assigned before the probe routine =
is
> invoked, because the settings in the chip registers are done only at =
probe
> time. Is there a way to change this value and have it take effect whe=
n
> changed by ethtool?
>
> Any other ideas are most welcome.
>
> Thanks,
> Chaitanya

Option 2 (using ethtool is the right way to go) as far as the driver,
there most likely will need some work to be done since they may not be
setup to handle the manual setting of MDI/MDIX parameter.

--=20
Cheers,
Jeff
