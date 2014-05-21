From: Linus Gasser <list@markas-al-nour.org>
Subject: Re: Bonding with tun-devices
Date: Wed, 21 May 2014 21:36:34 +0100
Message-ID: <537D0E52.9030901@markas-al-nour.org>
References: <537CB13A.3030100@markas-al-nour.org> <20140521155434.GC6295@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from virt.linusetviviane.ch ([78.46.227.60]:45406 "EHLO
	mail.profeda.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1752837AbaEUUgK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 16:36:10 -0400
In-Reply-To: <20140521155434.GC6295@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 21/05/14 16:54, Veaceslav Falico a =E9crit :
> On Wed, May 21, 2014 at 02:59:22PM +0100, Linus Gasser wrote:
>> Dear list,
>>
>> I'm trying to create a bonded interface using tun-devices created by=
 the
>>
>> ssh -NTCf -w 0:0
>>
>> command. The reason is that I'm behind a satellite connection with
>> per-stream limited bandwidth...
>>
>> On some older kernels everything was fine, and I could do:
>>
>> # ssh -NTCf -w 0:0 web
>> # ssh -NTCf -w 1:1 web
>> # modprobe bonding mode=3D0 miimon=3D100
>> # ifconfig bond0 172.16.0.1 netmask 255.255.255.0
>> # ifconfig bond0 hw ether 12:34:56:78:9a
>> # ifenslave bond0 tun0 tun1
>
> It should fail here, as tun (from the first approach*) doesn't have
> ndo_set_mac_address, and bonding relies on that, *unless* fail_over_m=
ac is
> set to 1.
>
> Could you try setting fail_over_mac =3D 1 on modprobe or via sysfs an=
d
> retesting?
>
> * I've tried to quickly recreate your setup but hit a panic (already
> submitted a fix).
>
> Also, enabling debug for bonding (via dynamic_debug or anything else)=
 and
> attaching the output would help a lot.

Hi,

OK, I tried to add "fail_over_mac=3D1" to the modprobe-call, but both w=
ith=20
"ifenslave" and "ip add" I get the same error. In the logs I found (wit=
h=20
fail_over_mac):

kernel: bonding: Ethernet Channel Bonding Driver: v3.7.1 (April 27, 201=
1)
kernel: bonding: MII link monitoring set to 100 ms
kernel: bonding: Warning: fail_over_mac only affects active-backup mode=
=2E
bonding: bond0: Warning: The first slave device specified does not=20
support setting the MAC address.
bonding: bond0: Warning: The first slave device specified does not=20
support setting the MAC address.

As far as I see, my kernel doesn't have dynamic_debug enabled. I'm in=20
the midst of downloading it - hold on for a day or two ;) If you can=20
tell me how I can debug otherwise, I'll be glad to do so.

Linus

>
> Thank you!
>
>>
>> on one side and
>>
>> # modprobe bonding mode=3D0 miimon=3D100
>> # ifconfig bond0 172.16.0.2 netmask 255.255.255.0
>> # ifconfig bond0 hw ether 12:35
>> # ifenslave -f bond0 tun0 tun1
>> # ping 172.16.0.1
>>
>> on the other side. On a newer kernel (>3.14) this doesn't work (at
>> least not on linux-armv7), while on 3.13 it does work under
>> linux-armv7. Now I've been told to use the iproute2-suite, as
>> ifenslave is deprecated. But if I try to do
>>
>> # ssh -NTCf -w 0:0 web
>> # ssh -NTCf -w 1:1 web
>> # ip link add name bond1 type bond
>> # ip link set dev tun0 master bond1
>>
>> it gives me an error
>>
>> RTNETLINK answers: Operation not supported
>>
>> Any idea what I'm doing wrong?
>>
>> Linus
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
