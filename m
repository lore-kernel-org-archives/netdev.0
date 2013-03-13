From: =?UTF-8?Q?Joel_Wir=C4=81mu_Pauling?= <joel@aenertia.net>
Subject: Re: [Bridge] [PATCH net-next 0/4] Allow bridge to function in
 non-promisc mode
Date: Thu, 14 Mar 2013 07:56:49 +1300
Message-ID: <CAKiAkGRo0cHT6dJz5esih2hb2=Rxk27KG2dWBLr3wD=frEWveA@mail.gmail.com>
References: <1363139126-13396-1-git-send-email-vyasevic@redhat.com>
 <473541363155743@web2d.yandex.ru> <51406D2D.30703@redhat.com>
 <20130313083932.6483876f@nehalam.linuxnetplumber.net> <51409F24.3070305@redhat.com>
 <20130313090921.05dbf6e2@nehalam.linuxnetplumber.net> <5140B1B3.2070205@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	"Oleg A. Arkhangelsky" <sysoleg@yandex.ru>
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:42817 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932802Ab3CMS5L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 14:57:11 -0400
Received: by mail-wg0-f52.google.com with SMTP id 15so287580wgd.7
        for <netdev@vger.kernel.org>; Wed, 13 Mar 2013 11:57:10 -0700 (PDT)
In-Reply-To: <5140B1B3.2070205@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I agree that this is a useful behavior, often we will use a bridge in
the same scenario (multiple virtio tap adapters belonging to VM's)
another scenario is when creating a bridge for chaining multiple VPN's
together.

-Joel

On 14 March 2013 06:04, Vlad Yasevich <vyasevic@redhat.com> wrote:
> On 03/13/2013 12:09 PM, Stephen Hemminger wrote:
>>
>> On Wed, 13 Mar 2013 11:45:40 -0400
>> Vlad Yasevich <vyasevic@redhat.com> wrote:
>>
>>> On 03/13/2013 11:39 AM, Stephen Hemminger wrote:
>>>>
>>>> On Wed, 13 Mar 2013 08:12:29 -0400
>>>> Vlad Yasevich <vyasevic@redhat.com> wrote:
>>>>
>>>>> On 03/13/2013 02:22 AM, "Oleg A. Arkhangelsky" wrote:
>>>>>>
>>>>>>
>>>>>>
>>>>>> 13.03.2013, 05:45, "Vlad Yasevich" <vyasevic@redhat.com>:
>>>>>>
>>>>>>> The series adds an ability for the bridge to function in
>>>>>>> non-promiscuous mode.
>>>>>>
>>>>>>
>>>>>> What is the practical applications for such setup? In other words,
>>>>>> in which cases I would want to put bridge into non-promiscuous
>>>>>> mode and specify some uplink ports?
>>>>>>
>>>>>
>>>>> On of the applications would be when bridge is an edge device servicing
>>>>> a VM deployment.  Each of the VMs knows the mac address that the guest
>>>>> has and may program that mac onto the uplinks.
>>>>
>>>>
>>>> Why wouldn't that environment just use macvlan?
>>>> Is it because changing libvirt is harder than changing the kernel?
>>>>
>>>
>>> No, because macvlan has a drawback that it doesn't easily let guests
>>> talk to the host.  Bridge is still most commonly used for just that
>>> reason.
>>>
>>> -vlad
>>
>>
>> Maybe fixing that with a flag to macvlan would be easier?
>>
>
> Not really.  macvlan to physical device could be made simple enough.
> However, physical to macvlan is non-trivial at all.
>
> We get around this right now by crating a macvlan on the host and
> have macvlan to macvlan communication essentially turning it into
> bridge.  But that doesn't work in all scenarios either.
>
> -vlad
