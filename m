From: Jesse Gross <jesse@nicira.com>
Subject: Re: 2.6.37 regression: adding main interface to a bridge breaks vlan
 interface RX
Date: Mon, 28 Feb 2011 13:37:34 -0800
Message-ID: <AANLkTimmbG3_GjYhoO7F46hOcRM3Fq_mNifk2PpLstPa@mail.gmail.com>
References: <4D32FC1C.3010905@simon.arlott.org.uk>
	<201101231845.20505.maciej.rutecki@gmail.com>
	<AANLkTimTz=kMmJ=YhyJv28WUrsbN=ygBt9e7dMJ3KGqB@mail.gmail.com>
	<201101241625.45367.maciej.rutecki@gmail.com>
	<loom.20110205T163216-459@post.gmane.org>
	<AANLkTi=-+1dnh5ab6nMwjwMx20jpirYyaASZ=dk4OExp@mail.gmail.com>
	<loom.20110206T203347-475@post.gmane.org>
	<4D4FE100.5090808@gmail.com>
	<loom.20110214T141934-88@post.gmane.org>
	<AANLkTimFC5drwt44C7Hpn4YJU-Njksr8Zkiv_RXK_oSL@mail.gmail.com>
	<loom.20110226T011347-702@post.gmane.org>
	<AANLkTikSvs7jF9BZzbsYkLAawpCH2h1Z0r09ft219uaa@mail.gmail.com>
	<loom.20110226T120245-774@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: chriss <mail_to_chriss@gmx.net>,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:37616 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752490Ab1B1Vl7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 16:41:59 -0500
Received: by vxi39 with SMTP id 39so3582177vxi.19
        for <netdev@vger.kernel.org>; Mon, 28 Feb 2011 13:41:58 -0800 (PST)
In-Reply-To: <loom.20110226T120245-774@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 26, 2011 at 3:51 AM, chriss <mail_to_chriss@gmx.net> wrote:
> Jesse Gross <jesse <at> nicira.com> writes:
>
>>
>> Can you confirm this by running tcpdump -eni br0? =A0I would expect =
that
>> you see the correct packets but without vlan tags.
>>
>
> Thats correct. i see the packets in br0 without tags and tagged in et=
h1. thats
> why i added the brouting rule in ebtables to drop it at eth1 and the =
it apears
> in eth1.3 (untagged)...

Putting a vlan device on eth1 actually affects the behavior of the
driver, which is why that works.  I suspect that if you put the vlan
device on both the physical interface and the bridge you would see
packets with tags on the bridge.

Regardless, the solution is to remove the dependency on vlan devices
by converting over to the new vlan model.  Francois, any chance that
you might have some time to look at this?
