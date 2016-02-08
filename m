From: =?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@gmail.com>
Subject: Re: [PATCH 8/9] rfkill: Userspace control for airplane mode
Date: Mon, 8 Feb 2016 12:22:32 -0500
Message-ID: <CA+A7VXVrbixa+DqiOfzuBkCTVy+f0GOTqiMqXs1sekXu1Q7ekQ@mail.gmail.com>
References: <1454946096-9752-1-git-send-email-jprvita@endlessm.com>
 <1454946096-9752-9-git-send-email-jprvita@endlessm.com> <1454947887.5325.8.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	Darren Hart <dvhart@infradead.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	platform-driver-x86@vger.kernel.org, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	linux@endlessm.com,
	=?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@endlessm.com>
To: Dan Williams <dcbw@redhat.com>
Return-path: <platform-driver-x86-owner@vger.kernel.org>
In-Reply-To: <1454947887.5325.8.camel@redhat.com>
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8 February 2016 at 11:11, Dan Williams <dcbw@redhat.com> wrote:
> On Mon, 2016-02-08 at 10:41 -0500, Jo=C3=A3o Paulo Rechi Vita wrote:
>> Provide an interface for the airplane-mode indicator be controlled
>> from
>> userspace. User has to first acquire the control through
>> RFKILL_OP_AIRPLANE_MODE_ACQUIRE and keep the fd open for the whole
>> time
>> it wants to be in control of the indicator. Closing the fd or using
>> RFKILL_OP_AIRPLANE_MODE_RELEASE restores the default policy.
>>
>> To change state of the indicator, the RFKILL_OP_AIRPLANE_MODE_CHANGE
>> operation is used, passing the value on "struct rfkill_event.soft".
>> If
>> the caller has not acquired the airplane-mode control beforehand, th=
e
>> operation fails.
>
> I'd like to clarify a bit, so tell me if I'm correct or not.  Using
> RFKILL_OP_AIRPLANE_MODE_CHANGE does not actually change any device
> state. It's just an indicator with no relationship to any of the
> registered rfkill switches, right?
>

Yes, that's correct, and it is the intended behavior.

> I wonder if setting RFKILL_OP_AIRPLANE_MODE_CHANGE(true) shouldn't al=
so
> softblock all switches, otherwise you can set airplane mode all day
> long with RFKILL_OP_AIRPLANE_MODE_CHANGE and it doesn't actually enab=
le
> airplane mode at all?
>

The idea behind it is to just provide the mechanism for userspace to
decide what exactly being in airplane mode means, so it would
set/unset the indicator in the right moment.

--
Jo=C3=A3o Paulo Rechi Vita
http://about.me/jprvita
