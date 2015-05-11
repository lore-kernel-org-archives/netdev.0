From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net] rtnl: don't send rtnl msg for unregistered iface
Date: Mon, 11 May 2015 19:53:55 +0200
Message-ID: <20150511175355.GA3130@nanopsycho>
References: <1431354346-4476-1-git-send-email-nicolas.dichtel@6wind.com>
 <20150511153741.GB2222@nanopsycho.mtl.com>
 <5550D2F1.5030100@6wind.com>
 <5550D584.9010703@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:34105 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751779AbbEKRyC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 13:54:02 -0400
Received: by wgic8 with SMTP id c8so109691740wgi.1
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 10:54:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5550D584.9010703@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, May 11, 2015 at 06:15:00PM CEST, nicolas.dichtel@6wind.com wrote:
>Le 11/05/2015 18:04, Nicolas Dichtel a =E9crit :
>>Le 11/05/2015 17:37, Jiri Pirko a =E9crit :
>>[snip]
>>>
>>>I don't think this is the correct way to fix this.
>>>
>>>How ifindex can be 0 here? Ifindex is set in register_netdevice and
>>>looking at bond_create, I don't see any call to __bond_opt_set befor=
e
>>>that. But since it apparently is, the ordering should be changed so
>>>register_netdevice is called first.
>I also don't see why we would prevent to register a bonding interface =
directly
>with the right mode.
>
>>bond_newlink =3D> bond_changelink =3D> __bond_opt_set
>>and then back to bond_newlink =3D> register_netdevice

I see it now. Why not to do register first, changelink later?
Or, change __bond_opt_set to call call_netdevice_notifiers only in case
dev->reg_state =3D=3D NETREG_REGISTERED? Looking at the other places th=
is
check happens, looks like a little helper like "netdev_check_registered=
"
might be convenient.
