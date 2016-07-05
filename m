From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: DCB Auto turn off when link become up with Intel 82599ES ixgbe driver
Date: Tue, 5 Jul 2016 08:38:12 -0700
Message-ID: <CAKgT0UdpbHSGdw1kyEa_YPy5tOX20Oxd4XY_S5_x_PQ=_4XEDw@mail.gmail.com>
References: <loom.20160705T170910-270@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: ayuj <ayuj.verma@gmail.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f44.google.com ([209.85.214.44]:34896 "EHLO
	mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752413AbcGEPiN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 11:38:13 -0400
Received: by mail-it0-f44.google.com with SMTP id j185so53271776ith.0
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2016 08:38:13 -0700 (PDT)
In-Reply-To: <loom.20160705T170910-270@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 5, 2016 at 8:17 AM, ayuj <ayuj.verma@gmail.com> wrote:
> I'm trying to configure DCB in back-to-back scenario.
> System details
>
> OS :- CentOS 7.2
> kernel 3.10.0-327.el7.x86_64
> lldpad:- lldpad v0.9.46
> dcbtool:- v0.9.46
> ixgbe :- ixgbe-4.3.15
>
> steps followed:-
>
> # modporbe ixgbe
> # service lldpad start
>     Redirecting to /bin/systemctl start  lldpad.service
>
>
> # service lldpad status
> Redirecting to /bin/systemctl status  lldpad.service
> =E2=97=8F lldpad.service - Link Layer Discovery Protocol Agent Daemon=
=2E
>    Loaded: loaded (/usr/lib/systemd/system/lldpad.service; disabled; =
vendor
> preset: disabled)
>    Active: active (running) since Tue 2016-07-05 05:49:12 EDT; 1s ago
>  Main PID: 133737 (lldpad)
>    CGroup: /system.slice/lldpad.service
>            =E2=94=94=E2=94=80133737 /usr/sbin/lldpad -t
>
> Jul 05 05:49:12 localhost.localdomain systemd[1]: Started Link Layer
> Discovery Protocol Agent Daemon..
> Jul 05 05:49:12 localhost.localdomain systemd[1]: Starting Link Layer
> Discovery Protocol Agent Daemon....
>
>
> # dcbtool gc p3p2 dcb
> Command:        Get Config
> Feature:        DCB State
> Port:           p3p2
> Status:         Successful
> DCB State:      off
>
> # dcbtool sc p3p2 dcb on
> Command:        Set Config
> Feature:        DCB State
> Port:           p3p2
> Status:         Successful
>
> # dcbtool gc p3p2 dcb
> Command:        Get Config
> Feature:        DCB State
> Port:           p3p2
> Status:         Successful
> DCB State:      on
>
>
> Similar configuration on another system.
>
> But as soon as I do "ifconfig p3p2 up and check dcb
>
> # dcbtool gc p3p2 dcb
> Command:        Get Config
> Feature:        DCB State
> Port:           p3p2
> Status:         Successful
> DCB State:      off
>
> Initially suspecting issue with lldpad daemon/ixgbe driver. I replace=
d them
> (downloaded from repo) with latest packages.
> Same behaviour observed.
>
> - Tried disabling other dcb features like fcoe. Same issue.
> - Disabled selinux etc
>
>
> Can any 1 help me regarding this.

I'm adding e1000-devel as that is the mailing list for the ixgbe mainta=
iners.

You might want to go through and also check the number of TCs and how
you have them mapped to your priority groups.  It is possible that one
end or the other may only have 1 TC configured and if I am not
mistaken that is interpreted as having DCB disabled by the hardware.

Hope that helps.

- Alex
