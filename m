From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [Xen-devel] [RFC v2 1/4] bridge: enable interfaces to opt out
 from becoming the root bridge
Date: Fri, 21 Feb 2014 13:02:35 +0000
Message-ID: <53074E6B.6030006@citrix.com>
References: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com> <1392433180-16052-2-git-send-email-mcgrof@do-not-panic.com> <20140216105754.63738163@nehalam.linuxnetplumber.net> <CAB=NE6WwbOXNLO_Mn42i7y62pEsmDOWd35B621eiJk4iaE3Hfg@mail.gmail.com> <1392803559.23084.99.camel@kazak.uk.xensource.com> <5304C13F.3030802@citrix.com> <CAB=NE6X6Vuo3iib0W-c5cxv0QBpnZtCC0sFyuULugQoEZAbRtg@mail.gmail.com> <20140219090855.610c0e04@nehalam.linuxnetplumber.net> <CAB=NE6UAqoiFAJdckE1d7cgMZnU6_=8X+N=tSc6qH2bgH08M7Q@mail.gmail.com> <20140220091958.62a8b444@nehalam.linuxnetplumber.net> <CAB=NE6WnMFkH7JPNt+ROiWEvhvZ03vdGr21STf75DV9fRaK=PA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <Ian.Campbell@citrix.com>, <kvm@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	<bridge@lists.linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAB=NE6WnMFkH7JPNt+ROiWEvhvZ03vdGr21STf75DV9fRaK=PA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20/02/14 20:24, Luis R. Rodriguez wrote:
> On Thu, Feb 20, 2014 at 9:19 AM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
>> On Wed, 19 Feb 2014 09:59:33 -0800 "Luis R. Rodriguez" <mcgrof@do-not-panic.com> wrote:
>>> On Wed, Feb 19, 2014 at 9:08 AM, Stephen Hemminger <stephen@networkplumber.org> wrote:
>>>>
>>>> Please only use the netlink/sysfs flags fields that already exist
>>>> for new features.
>>>
>>> Sure, but what if we know a driver in most cases wants the root block
>>> and we'd want to make it the default, thereby only requiring userspace
>>> for toggling it off.
>>
>> Something in userspace has to put the device into the bridge.
>> Fix the port setup in that tool via the netlink or sysfs flags in
>> the bridge. It should not have to be handled in the bridge looking
>> at magic flags in the device.
>
> Agreed that's the best strategy and I'll work on sending patches to
> brctl to enable the root_block preference. This approach however also
I don't think brctl should deal with any Xen specific stuff. I assume 
there is a misunderstanding in this thread: when I (and possibly other 
Xen folks) talk about "userspace" or "toolstack" here, I mean Xen 
specific tools which use e.g. brctl to set up bridges. Not brctl itself.
> requires a userspace upgrade. I'm trying to see if we can get an
> old-nasty-cryptic-hack practice removed from the kernel and we'd try
> to prevent future drivers from using it -- without requiring userspace
> upgrade. In this case the bad practice is to using a high static MAC
> address for mimicking a root block default preference. In order to
> remove that *without* requiring a userspace upgrade the dev->priv_flag
> approach is the only thing I can think of. If this would go in we'd
> replace the high static MAC address with a random MAC address to
> prevent IPv6 SLAAC / DAD conflicts. I'd document this flag and
> indicate with preference for userspace to be the one tuning these
> knobs.
>
> Without this we'd have to keep the high static MAC address on upstream
> drivers and let userspace do the random'ization if it confirms the
> userspace knob to turn the root block flag is available. Is the
> priv_flag approach worth the compromise to remove the root block hack
> practice?
>
>    Luis
>
