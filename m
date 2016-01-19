From: =?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@gmail.com>
Subject: Re: [PATCH] net/rfkill: Create "airplane mode" LED trigger
Date: Tue, 19 Jan 2016 15:27:12 -0500
Message-ID: <CA+A7VXWGF5eoa0zFmqef_oo-r2FoaD3jsy87w=-MXVjw22F7Ow@mail.gmail.com>
References: <1451142303-1872-1-git-send-email-jprvita@endlessm.com>
 <1451142303-1872-2-git-send-email-jprvita@endlessm.com> <6DC3AA8C-DDE9-44B8-91C5-94B1EB0DBE9A@holtmann.org>
 <1452076319.2541.3.camel@sipsolutions.net> <CA+A7VXW3Fsf2O_xnnZAWxieMMhSP2ngTbhtuJEB1JpMc6EFPxQ@mail.gmail.com>
 <1452200461.3141.19.camel@sipsolutions.net> <CA+A7VXWeUJHTnSiGGT2WZER=pAX7hhhhi2oQVeu4U8xSM5VZag@mail.gmail.com>
 <1453234129.23600.3.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Marcel Holtmann <marcel@holtmann.org>,
	Network Development <netdev@vger.kernel.org>,
	=?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@endlessm.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Darren Hart <dvhart@infradead.org>,
	platform-driver-x86@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453234129.23600.3.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Johannes,

On 19 January 2016 at 15:08, Johannes Berg <johannes@sipsolutions.net> =
wrote:
> Hi,
>
>> There was a misunderstanding of these semantics on my side, despite
>> this being documented in Documentation/rfkill.txt. Now I've realized
>> the semantic difference between 1."having all the individual switche=
s
>> of a certain type blocked at a certain moment" and 2."blocking all
>> switches of a certain type": on the 1st situation, each switch was
>> individually blocked in different moments, and by chance a certain
>> type had all its registered switches blocked, while on the 2nd, all
>> switches of a certain type were blocked altogether using
>> RFKILL_OP_CHANGE_ALL. Only on the 2nd situation we want to update th=
e
>> default state for hotplugged devices, and that's why
>> rfkill_global_states[type] is not updated when individual switches
>> are
>> driven, even if we read situation 1. Then there is actually no
>> difference between the state value and the operation, and there is
>> nothing to be fixed on an individual switch change. Sorry for the
>> confusion.
>
> Ok, glad you have that cleared up because I'm not sure I understand
> what you were confused about :)
>
>> I'm going to add a note about this behavior to
>> include/uapi/linux/rfkill.h as well.
>
> If it helps the next person, sure!
>
>> >  * allow only a single userspace owner, and require that owner to
>> >    toggle it as required, to avoid multiple userspace applications
>> >    stepping on each others' toes. This could be implemented by
>> > making
>> >    this a new /dev/rfkill command, and requiring the fd to be held
>> >    open while controlling the airplane mode state.
>> >
>>
>> And when the fd gets released we would fallback to default, right?
>
> Yeah, I guess so. Something has to be known to be controlling it, and
> two applications can't really do it at the same time.
>

Ack.

>>  So
>> that would avoid two userpace apps trying to control it at the same
>> time, but not one after the other (which is a good thing). As I
>> understand it also implies we would not expose this control point
>> through sysfs.
>
> Yes, and I agree, sysfs wouldn't make a lot of sense for this (since
> you can't track ownership that way.)
>

Yes, that's what I thought.

>> Great, I already fixed the previous comments and started working on =
a
>> prototype of the second stage, but then a naming question came to my
>> mind. They way I'm designing it is to have only one trigger and
>> change
>> its behavior when the "airplane mode indicator" is under userspace
>> control (basically changing when to call led_trigger_event() to fire
>> the trigger). In this case it probably makes sense to call the
>> trigger
>> something like "rfkill-airplane_mode", as before, because it will
>> fire when we're in an "airplane safe" mode, controlled by userspace
>> or with a fallback default behavior.
>
> Sure.
>

Ack.

>> Another option would be to have two separate triggers,
>> "rfkill-airplane_mode" controlled by userspace, and "rfkill-all"
>> implementing the default behavior, and change which trigger is set t=
o
>> each LED *from the trigger implementation side* in rfkill. Unless I'=
m
>> missing something, I don't think this second approach is possible.
>
> Yes, this doesn't make sense.
>

Ok, good to know :)

>> So the question is, if we go with the 1st approach, would it be fine
>> to call the trigger "rkill-airplane_mode", even for the first stage
>> when only the default behavior is implemented, or should I rename it
>> (which implies renaming an API to other drivers) during the 2nd stag=
e
>> implementation? I think sticking with one name from the beginning is
>> better, but since it goes against previous feedback, I decided to as=
k
>> first.
>
> Indeed, I think it's better. I wasn't previously considering (much) t=
he
> possibility of enhancing the framework :)
>
> Thanks for your work on this - I see also your patches already, will =
go
> over them soon; I'm working part-time on parental leave right now, so=
 things take a bit longer than usual.
>

Thanks for the clarifications! I'll clean-up the patches that actually
implement this (the ones I've send are only general
fixes/improvements) and send them in the next days.

Don't worry about delays, enjoy your parental leave!
