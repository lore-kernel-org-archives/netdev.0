From: Anatol Pomozov <anatol.pomozov@gmail.com>
Subject: Re: [RFC v2 3/6] kthread: warn on kill signal if
	not OOM
Date: Wed, 15 Oct 2014 12:41:42 -0700
Message-ID: <CAOMFOmW2r2SyRVLAdZTV_1wK+gRES-hQXHGUGnWA=kvv6P3KXQ@mail.gmail.com>
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
 <CAOMFOmVSwPAbPtNzPn93QGjbXh1B3QC7B2Ahd1Qxc=gWb6H7fQ@mail.gmail.com>
 <CAG-2HqXdxHrx4OL4E0TnzA1Fb6zK6J+qowfD0RHCwviGUv-_ng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
 Takashi Iwai <tiwai@suse.de>, Kay Sievers <kay@vrfy.org>,
 Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
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
 Abhijit Mahajan <abhijit.mahajan@avagotech.com>,
 systemd Mailing List <systemd-devel@lists.freedesk
To: Tom Gundersen <teg@jklm.no>
Return-path: <systemd-devel-bounces@lists.freedesktop.org>
In-Reply-To: <CAG-2HqXdxHrx4OL4E0TnzA1Fb6zK6J+qowfD0RHCwviGUv-_ng@mail.gmail.com>
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

On Fri, Oct 10, 2014 at 3:45 PM, Tom Gundersen <teg@jklm.no> wrote:
> On Fri, Oct 10, 2014 at 11:54 PM, Anatol Pomozov
> <anatol.pomozov@gmail.com> wrote:
>> 1) Why not to make the timeout configurable through config file? There
>> is already udev.conf you can put config option there. Thus people with
>> modprobe issues can easily "fix" the problem. And then decrease
>> default timeout back to 30 seconds. I agree that long module loading
>> (more than 30 secs) is abnormal and should be investigated by driver
>> authors.
>
> We can already configure this either on the udev or kernel
> commandline, is that not sufficient (I don't object to also adding it
> to the config file, just asking)?

I did not know that udev timeout can be configured via kernel cmd. And
because other people ask about changing timeout they most like did not
know about it neither. Actually looking at
http://www.freedesktop.org/software/systemd/man/kernel-command-line.html
I do not see where it mentions udev timeout.

I think adding configuration to the right place (udev config file) and
adding documentation to make the option more discoverable will solve
the topic starter issue. Now anyone can easily set timeout they want.
The default timeout can go back to 30 sec in this case.

>> 2) Could you add 'echo w > /proc/sysrq-trigger' to udev code right
>> before killing the "modprobe" thread? sysrq will print information
>> about stuck threads (including modprobe itself) this will make
>> debugging easier. e.g. dmesg here
>> https://bugs.archlinux.org/task/40454 says nothing where the threads
>> were stuck.
>
> Are the current warnings (in udev git) sufficient (should tell you
> which module is taking long, but still won't tell you which kernel
> thread of course)?

True. module name should be enough. In this case to debug the issue user needs:
 - disable failing udev rule (or blacklist module?)
 - reboot, it will let the user get into shell
 - modprobe the failing module
 - use sysrq-trigger to get more information about stuck process

So it is more matter of easier problem debugging. Not critical but it
will be useful imho. This feature can be configured via udev.conf
