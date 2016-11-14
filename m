From: Mason <slash.tmp@free.fr>
Subject: Re: Debugging Ethernet issues
Date: Mon, 14 Nov 2016 21:27:43 +0100
Message-ID: <582A1E3F.8040908@free.fr>
References: <5827AD4A.7010908@free.fr> <20161113030919.GA2892@lunn.ch>
 <5828C452.6050808@free.fr> <9d1f28a7-959b-fdde-3403-f6da5f521125@gmail.com>
 <5829BBFC.7040800@free.fr> <20161114133428.GF26710@lunn.ch>
 <5829D10F.30206@free.fr> <5829D95C.6060509@free.fr>
 <3313424a-8d45-0883-5257-ffdc250dd45b@gmail.com>
 <5829FB6F.6090106@laposte.net>
 <2187db98-dc5a-7a3c-7965-7ccbeffc0fa1@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Sebastian Frias <sf84@laposte.net>, Andrew Lunn <andrew@lunn.ch>,
        netdev <netdev@vger.kernel.org>, Mans Rullgard <mans@mansr.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Tom Lendacky <thomas.lendacky@amd.com>,
        Zach Brown <zach.brown@ni.com>,
        Shaohui Xie <shaohui.xie@nxp.com>,
        Tim Beale <tim.beale@alliedtelesis.co.nz>,
        Brian Hill <brian@houston-radar.com>,
        Vince Bridgers <vbridgers2013@gmail.com>,
        Balakumaran Kannan <kumaran.4353@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Kirill Kapranov <kapranoff@inbox.ru>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:7133 "EHLO smtp2-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932462AbcKNU2W (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Nov 2016 15:28:22 -0500
In-Reply-To: <2187db98-dc5a-7a3c-7965-7ccbeffc0fa1@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/11/2016 19:20, Florian Fainelli wrote:

> On 11/14/2016 09:59 AM, Sebastian Frias wrote:
>
>> Could you confirm that Mason's patch is correct and/or that it does not
>> has negative side-effects?
> 
> The patch is not correct nor incorrect per-se, it changes the default
> policy of having pause frames advertised by default to not having them
> advertised by default. This influences both your Ethernet MAC and the
> link partner in that the result is either flow control is enabled
> (before) or it is not (with the patch). There must be something amiss if
> you see packet loss or some kind of problem like that with an early
> exchange such as DHCP. Flow control tend to kick in under higher packet
> rates (at least, that's what you expect).

Did you note that, without the change under discussion (i.e. with
the eth driver as it is upstream), when the board is connected to
a 100 Mbps switch, then *nothing* works *systematically (no ping,
no DHCP; are there other relevant low-level network tools?).

Also, maybe this comment was lost in my own noise:

If I manually set the link up, then down, then run udhcpc
=> then nothing works, as if something is wedged somewhere
(a kernel thread gets borked by a race condition?)

Could not advertising pause frames result in making such a
race condition impossible? (I don't really believe in a race,
due to the 100% nature of the problem.)

>> Right now we know that Mason's patch makes this work, but we do not understand
>> why nor its implications.
> 
> You need to understand why, right now, the way this problem is
> presented, you came up with a workaround, not with the root cause or the
> solution. What does your link partner (switch?) reports, that is, what
> is the ethtool output when you have a link up from your nb8800 adapter?

Isn't that what ethtool -a eth0 prints?
How do I get the link partner information?
Just ethtool eth0?

Regards.
