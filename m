From: =?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@gmail.com>
Subject: Re: [PATCH 8/9] rfkill: Userspace control for airplane mode
Date: Tue, 16 Feb 2016 10:12:45 -0500
Message-ID: <CA+A7VXWuMfGpLCyv+veq1GxMzZe+P1F99470KT7B_Q3+6v9fdQ@mail.gmail.com>
References: <1454946096-9752-1-git-send-email-jprvita@endlessm.com>
 <1454946096-9752-9-git-send-email-jprvita@endlessm.com> <1454947887.5325.8.camel@redhat.com>
 <1455120444.4991.1.camel@sipsolutions.net> <1455123205.19821.34.camel@redhat.com>
 <ec4b7edcda0a62cd4e36e501f5ad56f9@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Williams <dcbw@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Darren Hart <dvhart@infradead.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	platform-driver-x86@vger.kernel.org, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	linux@endlessm.com,
	=?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@endlessm.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <ec4b7edcda0a62cd4e36e501f5ad56f9@sipsolutions.net>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10 February 2016 at 12:12, Johannes Berg <johannes@sipsolutions.net>=
 wrote:
> On 2016-02-10 17:53, Dan Williams wrote:
>>
>> Yeah, I get that now.  It's just that to me, something called
>> "AIRPLANE_MODE_CHANGE" seems like it should actually change airplane
>> mode on/off, which implies killing radios.  I wouldn't have had the
>> problem if it was named AIRPLANE_MODE_INDICATOR_CHANGE, which makes =
it
>> clear this is simply an indicator and has no actual effect on anythi=
ng
>> other than a LED.
>

I also agree the AIRPLANE_MODE_INDICATOR_* prefix makes things more
clear here. Thanks for the feedback, Dan!

>
> Yeah, I agree. I'm not even sure that it's a good idea to subsume thi=
s into
> the regular operations in the API, although that's obviously the easi=
est
> extension. I'll need to think about that a bit more with the code at =
hand
> though.
>

Initially I have thought about creating and additional RFKill switch
for that, but I think it would be a bit hackish since we would have to
treat it specially in sysfs attributes and probably other places, and
userspace would also need a special case when going through the list
of RFKill switches in the system. The proposed solution has equivalent
semantics to an RFKill switch, is backward-compatible (users would
only ignore the unknown operations and evens -- although gsd has a
"default:" case to abort execution on an unknown event) and does not
extend the RFKill event struct.

One alternative would be to move the control point to a separate
device, like /dev/rfkill-airplane-mode, but I'm not sure this is a
very elegant approach. Anyway, I'm open to work on changes to the API,
but it would be great if you could at least pick or reject the
non-polemical patches of the series, so I don't need to carry them
anymore.

--
Jo=C3=A3o Paulo Rechi Vita
http://about.me/jprvita
