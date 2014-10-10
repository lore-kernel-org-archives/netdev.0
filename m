From: Anatol Pomozov <anatol.pomozov@gmail.com>
Subject: Re: [RFC v2 3/6] kthread: warn on kill signal if
	not OOM
Date: Fri, 10 Oct 2014 14:54:14 -0700
Message-ID: <CAOMFOmVSwPAbPtNzPn93QGjbXh1B3QC7B2Ahd1Qxc=gWb6H7fQ@mail.gmail.com>
References: <1409899047-13045-1-git-send-email-mcgrof@do-not-panic.com>
 <CAB=NE6Wti1RpAFk5q_YeZn2F9Rd=wsiwhyPszu74nG9fXwH5vQ@mail.gmail.com>
 <20140905141241.GC10455@mtj.dyndns.org>
 <20140905164405.GA28964@core.coreip.homeip.net>
 <20140905174925.GA12991@mtj.dyndns.org>
 <CAB=NE6VPTV39pNujOgO422wbUvU44HZ7s=aaxPVraNECqA6e4Q@mail.gmail.com>
 <20140905224047.GC15723@mtj.dyndns.org>
 <CAB=NE6Uz1VD5qpMFSBfQRV8ih9FQcCUhNtWMvD38t5hdDvix4Q@mail.gmail.com>
 <20140909011059.GB11706@mtj.dyndns.org>
 <1410241109.2028.22.camel@jarvis.lan>
 <CAB=NE6WGAMvffGDTkN5x5Cd+YOtD-Cmo3v7_8FmJ5cvCRbFEpw@mail.gmail.com>
 <1410291346.13298.16.camel@jarvis.lan>
 <CAB=NE6U6v-GhAaZv3yXn9uVFvBvE4Uq8z7MQU8N+CyW19WpnNQ@mail.gmail.com>
 <CAG-2HqUiUksdT4UyeDsdc1Q74=2BiX2TuzzGh_hoLiO5_DOvXQ@mail.gmail.com>
 <CAB=NE6UprJH69hzc1mjqyq6PAn+7LZmX65Z8CDwUdJ73nDusHg@mail.gmail.com>
 <CAG-2HqUzCvd55mq=M3=tXbHAjc2QnVuRtbFZMWTz9k_6BmmngQ@mail.gmail.com>
 <CAB=NE6XmFaWMKuW3vJ7QMZ1BmmWrAPezTYYsqatX4mMNdMjpog@mail.gmail.com>
 <CAG-2HqWYXo+uRtOk_XW-Bi5aXcTLphEMLCMy8a2THuEg9dHPzw@mail.gmail.com>
 <CAB=NE6XS9pWmfO7xjTpLFG1OdOJ=UktbOK5pjJCK8hzfXagfXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
 Takashi Iwai <tiwai@suse.de>, Kay Sievers <kay@vrfy.org>,
 Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
 Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
 hare <hare@suse.com>,
 Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
 Wu Zhangjin <falcon@meizu.com>,
 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
 "mpt-fusionlinux.pdl" <MPT-FusionLinux.pdl@avagotech.com>,
 Tim Gardner <tim.gardner@canonical.com>, Benjamin Poirier <bpoirier@suse.de>,
 Santosh Rastapur <santosh@chelsio.com>, Casey Leedom <leedom@chelsio.com>,
 Hariprasad S <hariprasad@chelsio.com>,
 Pierre Fersing <pierre-fersing@pierref.org>,
 Arjan van de Ven <arjan@linux.intel.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Abhijit Mahajan <abhijit.mahajan@avagotech.com>,
 systemd Mailing List <systemd-devel@lists.freedesktop.org>,
 Lin
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <systemd-devel-bounces@lists.freedesktop.org>
In-Reply-To: <CAB=NE6XS9pWmfO7xjTpLFG1OdOJ=UktbOK5pjJCK8hzfXagfXQ@mail.gmail.com>
List-Unsubscribe: <http://lists.freedesktop.org/mailman/options/systemd-devel>,
 <mailto:systemd-devel-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <http://lists.freedesktop.org/archives/systemd-devel>
List-Post: <mailto:systemd-devel@lists.freedesktop.org>
List-Help: <mailto:systemd-devel-request@lists.freedesktop.org?subject=help>
List-Subscribe: <http://lists.freedesktop.org/mailman/listinfo/systemd-devel>,
 <mailto:systemd-devel-request@lists.freedesktop.org?subject=subscribe>
Errors-To: systemd-devel-bounces@lists.freedesktop.org
Sender: "systemd-devel" <systemd-devel-bounces@lists.freedesktop.org>
List-Id: netdev.vger.kernel.org

Hi

On Fri, Sep 12, 2014 at 1:09 PM, Luis R. Rodriguez
<mcgrof@do-not-panic.com> wrote:
> On Thu, Sep 11, 2014 at 10:48 PM, Tom Gundersen <teg@jklm.no> wrote:
>> On Fri, Sep 12, 2014 at 12:26 AM, Luis R. Rodriguez
>> <mcgrof@do-not-panic.com> wrote:
>>> On Thu, Sep 11, 2014 at 2:43 PM, Tom Gundersen <teg@jklm.no> wrote:
>>>> How about simply introducing a new flag to finit_module() to indicate
>>>> that the caller does not care about asynchronicity. We could then pass
>>>> this from udev, but existing scripts calling modprobe/insmod will not
>>>> be affected.
>>>
>>> Do you mean that you *do want asynchronicity*?
>>
>> Precisely, udev would opt-in, but existing scripts etc would not.
>
> Sure that's the other alternative that Tejun was mentioning.
>
>>>> But isn't finit_module() taking a long time a serious problem given
>>>> that it means no other module can be loaded in parallel?
>>>
>>> Indeed but having a desire to make the init() complete fast is
>>> different than the desire to have the combination of both init and
>>> probe fast synchronously.
>>
>> I guess no one is arguing that probe should somehow be required to be
>> fast, but rather:
>>
>>> If userspace wants init to be fast and let
>>> probe be async then userspace has no option but to deal with the fact
>>> that async probe will be async, and it should then use other methods
>>> to match any dependencies if its doing that itself.
>>
>> Correct. And this therefore likely needs to be opt-in behaviour per
>> finit_module() invocation to avoid breaking old assumptions.
>
> Sure.
>
>>> For example
>>> networking should not kick off after a network driver is loaded but
>>> rather one the device creeps up on udev. We should be good with
>>> networking dealing with this correctly today but not sure about other
>>> subsystems. depmod should be able to load the required modules in
>>> order and if bus drivers work right then probe of the remnant devices
>>> should happen asynchronously. The one case I can think of that is a
>>> bit different is modules-load.d things but those *do not rely on the
>>> timeout*, but are loaded prior to a service requirement. Note though
>>> that if those modules had probe and they then run async'd then systemd
>>> service would probably need to consider that the requirements may not
>>> be there until later. If this is not carefully considered that could
>>> introduce regression to users of modules-load.d when async probe is
>>> fully deployed. The same applies to systemd making assumptions of kmod
>>> loading a module and a dependency being complete as probe would have
>>> run it before.
>>
>> Yeah, these all needs to be considered when deciding whether or not to
>> enable async in each specific case.
>
> Yes and come to think of it I'd recommend opting out of async
> functionality for modules-load.d given that it does *not* hooked with
> the timeout and there is a good chances its users likely do want to
> wait for probe to run at this point.
>
> Given this I also am inclined now for the per module request to be
> async or not (default) from userspace. The above would be a good
> example starting use case.
>
>>> I believe one concern here lies in on whether or not userspace
>>> is properly equipped to deal with the requirements on module loading
>>> doing async probing and that possibly failing. Perhaps systemd might
>>> think all userspace is ready for that but are we sure that's the case?
>>
>> There almost certainly are custom things out there relying on the
>> synchronous behaviour, but if we make it opt-in we should not have a
>> problem.


We recently discussed this "timeout module loading" issue in Arch IRC
and here are few more ideas:

1) Why not to make the timeout configurable through config file? There
is already udev.conf you can put config option there. Thus people with
modprobe issues can easily "fix" the problem. And then decrease
default timeout back to 30 seconds. I agree that long module loading
(more than 30 secs) is abnormal and should be investigated by driver
authors.

2) Could you add 'echo w > /proc/sysrq-trigger' to udev code right
before killing the "modprobe" thread? sysrq will print information
about stuck threads (including modprobe itself) this will make
debugging easier. e.g. dmesg here
https://bugs.archlinux.org/task/40454 says nothing where the threads
were stuck.
